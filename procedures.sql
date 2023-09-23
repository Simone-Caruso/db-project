-- =============================================================================
--
--                          STORED PROCEDURE
--
-- =============================================================================

USE HotelStatistics;

-- -----------------------------------------------------------------------------

/* Dato il codice di una prenotazione di una stanza stampare le informazioni di
tutte le persone che sono stati ospitati nella stanza senza aver prenotato a 
loro nome e per ognuna di esse il codice della relativa prenotazione. */

DELIMITER //

CREATE PROCEDURE dati_prenotazione( IN id_prenotazione CHAR(10) ) 

BEGIN

SELECT PS.IdPrenotazione, P.CF CF, P.Nome Nome, P.Cognome Cognome, 
       P.DataNascita DataNascita, P.Mail Mail, P.Telefono Telefono

FROM PrenotazioneStanza PS
   JOIN Ospite O
   ON IdPrenotazione = PrenotazioneStanza
   JOIN Persona P
   ON O.Persona = P.CF

WHERE IdPrenotazione = id_prenotazione AND 
      PS.Persona IS NOT NULL AND
      O.Persona <> PS.Persona;

END //

DELIMITER ;

-- -----------------------------------------------------------------------------


/* Eliminare le fatture di ordine più vecchie di X anni 
NOTA: questo tipo di stored procedure deve essere transazionale:
tutti i record desiderati devono essere eliminati, altrimenti nessuno.
La base di dati non può trovarsi in uno stato parziale (inconsistente) */

DELIMITER //

SET AUTOCOMMIT = 0;

CREATE PROCEDURE elimina_vecchi_ordini( IN var_anni INT UNSIGNED )

BEGIN

  DECLARE var_rownum INT UNSIGNED DEFAULT 0;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

  START TRANSACTION;

    DELETE FROM Ordine
    WHERE Fattura IN (SELECT IdFattura 
                      FROM FatturaOrdine 
                      WHERE TIMESTAMPDIFF(YEAR, Data, CURDATE()) >= var_anni);
    
    DELETE FROM FatturaOrdine 
    WHERE TIMESTAMPDIFF(YEAR, Data, CURDATE()) >= var_anni;

    SELECT count(*) INTO var_rownum
    FROM FatturaOrdine
    WHERE TIMESTAMPDIFF(YEAR, Data, CURDATE()) >= var_anni;

    IF var_rownum > 0 THEN
      SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT="Errore cancellazione";
    END IF;

  COMMIT;

END //

DELIMITER ;

-- -----------------------------------------------------------------------------

/* Stampare sulla stessa riga per ogni hotel il numero di manutenzioni per 
categoria eseguite in quell'hotel per un dato anno. */

DELIMITER //

CREATE PROCEDURE print_report_manutenzioni(IN var_anno INT UNSIGNED)

BEGIN

SELECT YEAR(AM.Data) Anno, AM.NomeHotel, AM.ViaHotel, AM.CittaHotel,
  SUM(CASE WHEN AM.Categoria = "Idraulica" THEN 1 ELSE 0 END) "Manutenzioni Idrauliche",
  SUM(CASE WHEN AM.Categoria = "Elettrica" THEN 1 ELSE 0 END) "Manutenzioni Elettriche",
  SUM(CASE WHEN AM.Categoria = "Pulizia" THEN 1 ELSE 0 END) "Manutenzioni Pulizie",
  SUM(CASE WHEN AM.Categoria = "Edile" THEN 1 ELSE 0 END) "Manutenzioni Edili",
  SUM(CASE WHEN AM.Categoria = "Arredo" THEN 1 ELSE 0 END) "Manutenzioni Arredo"
FROM AttivitaManutenzione AM
WHERE YEAR(AM.Data) = var_anno
GROUP BY YEAR(AM.Data), AM.NomeHotel, AM.ViaHotel, AM.CittaHotel;


END //

DELIMITER ;

-- -----------------------------------------------------------------------------

/* Stampare sulla stessa riga per ogni hotel il numero di pagamenti 
per tipo di pagamento e l'incasso totale per tutte le fatture di preotazione per un dato anno. */

DELIMITER //

CREATE PROCEDURE print_report_pagamenti(IN var_anno INT UNSIGNED)

BEGIN

SELECT YEAR(FP.Data) Anno, PS.NomeHotel,PS.ViaHotel, PS.CittaHotel,
  SUM(CASE WHEN FP.TipoPagamento = "Bonifico" THEN 1 ELSE 0 END) "Numero Pagamenti con Bonifico",
  SUM(CASE WHEN FP.TipoPagamento = "Carta" THEN 1 ELSE 0 END) "Numero Pagamenti con Carta",
  SUM(CASE WHEN FP.TipoPagamento = "Contanti" THEN 1 ELSE 0 END) "Numero Pagamenti con Contanti",
  SUM(FP.Totale) "Incasso Totale"
FROM FatturaPrenotazione FP
JOIN PrenotazioneStanza PS
ON FP.PrenotazioneStanza = PS.IdPrenotazione
WHERE YEAR(FP.Data) = var_anno
GROUP BY YEAR(FP.Data), PS.NomeHotel, PS.ViaHotel, PS.CittaHotel;

END //

DELIMITER ;
