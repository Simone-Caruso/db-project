-- =============================================================================
--
--                              VIEWS
--
-- =============================================================================

USE HotelStatistics;

/* vista con il nome, cognome e telefono di tutte le persone attualmente ospitate
 nella catena alberghiera.
*/

CREATE VIEW OspitiAttuali(Nome,Cognome,Telefono) AS
SELECT P.Nome,P.Cognome,P.Telefono
FROM Ospite O
 JOIN Persona P 
 ON O.Persona = P.CF
 JOIN PrenotazioneStanza PS
 ON O.PrenotazioneStanza = PS.IdPrenotazione
WHERE (CURDATE() BETWEEN PS.DataInizio AND PS.DataFine);

/*
Per ogni anno per ogni hotel, si vogliono sapere il numero di prenotazioni
*/

CREATE VIEW NumeroPrenotazioniAnnuali(Anno,NomeHotel,ViaHotel,CittaHotel,NumeroPrenotazioni) AS

SELECT YEAR(DataFine),NomeHotel, ViaHotel, CittaHotel, count(*) as NumeroPrenotazioni

FROM PrenotazioneStanza PS

GROUP BY YEAR(DataFine),NomeHotel, ViaHotel, CittaHotel ;


/*
Una vista per oscurare il numero di telefono e mail di tutte le Persone
*/

CREATE VIEW DataPrivacyPersona(CF,Nome,Cognome,Mail,Telefono,DataNascita) AS

SELECT CF,Nome,Cognome, concat(substr(Mail,1,2), '*****', substr(Mail,-4)) Mail, 
                        concat(substr(Telefono,1,2), '*****') Telefono, DataNascita
FROM Persona ;


/*
Di ogni società il numero di prenotazioni fatte nell'intera catena alberghiera
*/

CREATE VIEW NumeroPrenotazioniSocieta(PartivaIVA, Nome, Mail, Telefono, NumeroPrenotazioni) AS

SELECT S.PartitaIVA, S.Nome, S.Mail, S.Telefono, count(*) as NumeroPrenotazioni 
FROM PrenotazioneStanza PS JOIN Societa S ON PS.Societa = S.PartitaIVA
WHERE PS.Societa IS NOT NULL
GROUP BY S.PartitaIVA, S.Nome, S.Mail, S.Telefono ;


/* Dell'anno attuale, le spese mensili totali di fornitura  di ogni servizio */

CREATE VIEW SpeseFornitureMensili(NomeHotel,ViaHotel,CittaHotel,NomeServizio,Mese,SpesaTotale) AS

SELECT S.NomeHotel, S.ViaHotel, S.CittaHotel, S.Nome, MONTH(FO.Data), SUM(O.Prezzo)

FROM Servizio S 
   JOIN FatturaOrdine FO    
   ON S.Nome = FO.NomeServizio AND S.NomeHotel = FO.NomeHotel AND S.CittaHotel = FO.CittaHotel AND S.ViaHotel = FO.ViaHotel
   JOIN Ordine O
   ON O.Fattura = FO.IdFattura

WHERE YEAR(FO.Data) = YEAR(CURDATE())

GROUP BY S.NomeHotel, S.ViaHotel, S.CittaHotel, S.Nome, MONTH(FO.Data) ;


