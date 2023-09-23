USE HotelStatistics;

/* Dato il codice di un prodotto, si vuole sapere la variazione del prezzo 
   rispetto al suo acquisto precedente. */

DELIMITER //

CREATE FUNCTION variazione_prodotto(var_idProdotto VARCHAR(15))
RETURNS DECIMAL(7,2)
DETERMINISTIC

BEGIN

  DECLARE done INT DEFAULT FALSE;
  
  DECLARE idFattura CHAR(14);
  DECLARE idProdotto VARCHAR(15) DEFAULT var_idProdotto;
  DECLARE dataFattura DATE;
  DECLARE quantitaOrdine INT UNSIGNED;
  DECLARE prezzoOrdine DECIMAL(7,2);
  DECLARE variazionePrezzo DECIMAL(7,2) DEFAULT 0;
  DECLARE numeroTuple INT UNSIGNED DEFAULT 0;

  DECLARE cur CURSOR FOR 

  SELECT P.IdProdotto, FO.IdFattura, FO.Data, O.Quantita, O.Prezzo

   FROM Prodotto P
   JOIN Ordine O
   ON P.IdProdotto = O.Prodotto
   JOIN FatturaOrdine FO
   ON O.Fattura = FO.IdFattura

   WHERE P.IdProdotto = var_idProdotto
   ORDER BY FO.Data DESC
   LIMIT 2;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  
  readLoop : LOOP

  FETCH cur INTO idProdotto, idFattura, dataFattura, quantitaOrdine, prezzoOrdine; 
  
  IF DONE THEN
   LEAVE readLoop;
  END IF; 

  SET variazionePrezzo = (prezzoOrdine/quantitaOrdine - variazionePrezzo);
  SET numeroTuple = numeroTuple + 1;
  
  END LOOP;

CLOSE cur;

IF numeroTuple < 2 THEN
    signal sqlstate '45001' SET message_text='Record non sufficienti';
  END IF;

RETURN variazionePrezzo*(-1);

END //
DELIMITER ;


/* Cursore per contare il numero di righe di una tabella */

DELIMITER //

CREATE FUNCTION conta_righe()
RETURNS INT
DETERMINISTIC

BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE numeroTuple INT UNSIGNED DEFAULT 0;
DECLARE idProdotto VARCHAR(15);

DECLARE cur CURSOR FOR

  SELECT P.IdProdotto

   FROM Prodotto P
   JOIN Ordine O
   ON P.IdProdotto = O.Prodotto
   JOIN FatturaOrdine FO
   ON O.Fattura = FO.IdFattura

   WHERE P.IdProdotto = '0077970854924'
   ORDER BY FO.Data DESC;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
   OPEN cur;
   
   readLoop : LOOP
   
   FETCH cur INTO idProdotto;
   
   
     IF DONE THEN
     LEAVE readLoop;
     END IF;
     
    SET numeroTuple = numeroTuple + 1;
   
   END LOOP;
   
   CLOSE cur;
   
RETURN numeroTuple;
   
END //

DELIMITER ;
