-- =============================================================================
--
--                              TRIGGERS
--
-- =============================================================================

USE HotelStatistics;

/*
 Una stanza Non deve avere più prenotazioni con periodo di permanenza sovrapponibili.
*/

DELIMITER //

CREATE TRIGGER prenotazione_before_insert
BEFORE INSERT ON PrenotazioneStanza FOR EACH ROW

BEGIN

DECLARE numero_prenotazioni_sovrapponibili INT UNSIGNED;

SELECT count(*) INTO numero_prenotazioni_sovrapponibili
FROM PrenotazioneStanza PS
WHERE PS.Stanza = NEW.Stanza AND
      PS.NomeHotel = NEW.NomeHotel AND
      PS.ViaHotel = NEW.ViaHotel AND
      PS.CittaHotel = NEW.CittaHotel AND
     ((PS.DataInizio BETWEEN NEW.DataInizio AND NEW.DataFine) OR
      (PS.DataFine BETWEEN NEW.DataInizio AND NEW.DataFine));

IF( numero_prenotazioni_sovrapponibili >= 1 ) THEN
    
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT='Non è possibile prenotare la stanza per il periodo di permanenza indicato';

END IF;

END //

DELIMITER ;


/*
 Il numero di posti della prenotazione di una stanza deve essere minore o uguale
 al numero di posti della stanza prenotata.
*/

DELIMITER //

CREATE TRIGGER prenotazione2_before_insert
BEFORE INSERT ON PrenotazioneStanza FOR EACH ROW

BEGIN

DECLARE numero_posti_stanza INT UNSIGNED;

SELECT S.NumPosti INTO numero_posti_stanza
FROM Stanza S
WHERE S.IdStanza = NEW.Stanza AND S.NomeHotel = NEW.NomeHotel AND
   S.ViaHotel = NEW.ViaHotel AND S.CittaHotel = NEW.CittaHotel;


IF (numero_posti_stanza < NEW.NumPosti) THEN

SIGNAL SQLSTATE '45002' 
SET MESSAGE_TEXT='I posti della stanza prenotata sono insufficienti !';

END IF;

END //

DELIMITER ;


/*
 Il numero di ospiti di una stanza prenotata deve essere uguale al numero di 
 posti per la relativa prenotazione della stanza.
*/

DELIMITER //

CREATE TRIGGER ospite_before_insert
BEFORE INSERT ON Ospite FOR EACH ROW

BEGIN

DECLARE numero_ospiti_prenotazione int;
DECLARE numero_posti_prenotati int;

SELECT count(*) INTO numero_ospiti_prenotazione
FROM Ospite
WHERE PrenotazioneStanza = NEW.PrenotazioneStanza;

SELECT PS.NumPosti INTO numero_posti_prenotati
FROM PrenotazioneStanza PS
WHERE PS.IdPrenotazione = NEW.PrenotazioneStanza;

IF (numero_ospiti_prenotazione + 1) > numero_posti_prenotati THEN
SIGNAL SQLSTATE '45003' SET message_text='I posti della prenotazione sono già esauriti !';
END IF;

END //

DELIMITER ;


/*
 Una persona ospite di un hotel deve usare un servizio dell'hotel in cui è 
 ospitato e in una data compresa nel periodo di permanenza nell'hotel.
*/

DELIMITER //

CREATE TRIGGER usoservizio_before_insert
BEFORE INSERT ON UsoServizio FOR EACH ROW

BEGIN

DECLARE data_inizio DATE;
DECLARE data_fine DATE;
DECLARE prenotazione CHAR(10);
DECLARE done INT DEFAULT FALSE;
DECLARE result INT DEFAULT FALSE;


  DECLARE cur CURSOR FOR 
  SELECT PS.IdPrenotazione 
    FROM Ospite O 
    JOIN PrenotazioneStanza PS
    ON O.PrenotazioneStanza = PS.IdPrenotazione
    WHERE PS.NomeHotel = NEW.NomeHotel AND
    PS.ViaHotel = NEW.ViaHotel AND
    PS.CittaHotel = NEW.CittaHotel AND
    O.Persona = NEW.Persona;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  
  readLoop : LOOP

  FETCH cur INTO prenotazione; 
  
  IF DONE THEN
   LEAVE readLoop;
  END IF; 

  SELECT DataInizio, DataFine INTO data_inizio, data_fine
  FROM PrenotazioneStanza PS
  WHERE PS.IdPrenotazione = prenotazione;

  IF( (NEW.Data >= data_inizio AND NEW.Data <= data_fine) ) THEN
     SET result = TRUE;
  END IF;
  
  END LOOP;

  CLOSE cur;

  IF(result = FALSE ) THEN 
  SIGNAL SQLSTATE '45004' SET message_text= 'La persona non è stata ospite della struttura di cui ha usufruito il servizio';

END IF;

END //

DELIMITER ;


/*
 Il costo di prenotazione di una camera si ottiene moltiplicando il numero di 
 ospiti della prenotazione per il prezzo di pernottamento della camera prenotata
 e il numero di notti soggiornate.
*/

DELIMITER //

CREATE TRIGGER prezzo_fatturaprenotazione_before_insert
BEFORE INSERT ON FatturaPrenotazione FOR EACH ROW

BEGIN


DECLARE prezzo_stanza DECIMAL(6,2);
DECLARE numero_posti_prenotati INT UNSIGNED;
DECLARE numero_notti_soggiornate INT UNSIGNED;
DECLARE importo_soggiorno DECIMAL(8,2);

SET numero_notti_soggiornate = (SELECT DATEDIFF(DataFine,DataInizio) 
                                FROM PrenotazioneStanza 
                                WHERE IdPrenotazione = NEW.PrenotazioneStanza);

SELECT PS.NumPosti INTO numero_posti_prenotati
FROM PrenotazioneStanza PS
WHERE PS.IdPrenotazione = NEW.PrenotazioneStanza;

SELECT S.Prezzo INTO prezzo_stanza
FROM PrenotazioneStanza PS
JOIN Stanza S
ON PS.Stanza = S.IdStanza AND PS.NomeHotel=S.NomeHotel AND 
   PS.ViaHotel=S.ViaHotel AND PS.CittaHotel=PS.CittaHotel
WHERE PS.IdPrenotazione = NEW.PrenotazioneStanza;

SET importo_soggiorno = (prezzo_stanza * numero_posti_prenotati * numero_notti_soggiornate);


IF( NEW.Totale <> importo_soggiorno ) THEN
SET NEW.Totale = importo_soggiorno;
END IF;

END //

DELIMITER ;
