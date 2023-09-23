-- =============================================================================
--
--                              QUERIES
--
-- =============================================================================

USE HotelStatistics;

-- -----------------------------------------------------------------------------

/* Stampare nome, cognome e numero di telefono di tutte le 
persone che sono o sono stati ospiti in una stanza d'hotel. */

-- ANSI Style
SELECT DISTINCT p.Nome, p.Cognome, p.Telefono 
FROM Ospite o JOIN Persona p ON o.Persona = p.CF;

-- THETA Style
SELECT DISTINCT p.Nome, p.Cognome, p.Telefono
FROM Ospite o, Persona p
WHERE o.Persona = p.CF;


-- FULL TABLE SCAN VS INDEX ACCESS
SELECT /*! SQL_NO_CACHE */  p.Nome, p.Cognome, p.Telefono 
FROM Persona p
WHERE p.CF IN (SELECT Ospite.Persona FROM Ospite);


-- -----------------------------------------------------------------------------

/* Stampare le informazioni di tutti i convegni, il numero di partecipanti, il 
nome della sala convegno e dell'hotel dove sono stati presentati. */

SELECT C.Nome as Convegno, C.Data as Data, C.NomeHotel as Hotel,
S.Nome as NomeSala, count(*) as NumeroOspiti
FROM Convegno C, Stanza S, PrenotazioneStanza PS, Ospite O
WHERE C.Stanza = S.IdStanza AND
      C.NomeHotel = S.NomeHotel AND
      C.ViaHotel = S.ViaHotel AND
      C.CittaHotel = S.CittaHotel AND
      PS.Stanza = S.IdStanza AND
      PS.NomeHotel = S.NomeHotel AND
      PS.ViaHotel = S.ViaHotel AND
      PS.CittaHotel = S.CittaHotel AND
      PS.Stanza = S.IdStanza AND
      PS.NomeHotel = S.NomeHotel AND
      PS.ViaHotel = S.ViaHotel AND
      PS.CittaHotel = S.CittaHotel AND
      PS.IdPrenotazione = O.PrenotazioneStanza AND
      C.Data = PS.DataInizio
GROUP BY C.Nome,C.Data;

-- -----------------------------------------------------------------------------

/* Stampare nome, cognome e mail di tutti i partecipanti del/dei convegno/i con 
nome 'Database Administrator I' */

SELECT P.Nome,P.Cognome,P.Mail
FROM Convegno C 
JOIN PrenotazioneStanza PS
  ON C.Stanza = PS.Stanza AND 
     C.NomeHotel = PS.NomeHotel AND 
     C.ViaHotel = PS.ViaHotel AND 
     C.CittaHotel = PS.CittaHotel
JOIN Ospite O
  ON O.PrenotazioneStanza = PS.IdPrenotazione
JOIN Persona P
  ON P.CF = O.Persona
WHERE C.Nome = "Database Administrator I";

-- -----------------------------------------------------------------------------

/* Data la stanza N.186 dell'Hotel Overlook trovare (in ordine di DataInizio) se 
esistono le possibili prenotazioni con periodo di permanenza sovrapponibile al 
periodo con DataInizio 2021-10-08 e DataFine 2021-10-13. */

SELECT PS.IdPrenotazione, PS.DataInizio, PS.DataFine
FROM PrenotazioneStanza PS
WHERE PS.Stanza = 186 AND
      PS.NomeHotel = "Hotel Overlook" AND
      PS.ViaHotel = "Via Cavour 333" AND
      PS.CittaHotel = "Torino" AND
      ((PS.DataInizio BETWEEN "2021-10-08" AND "2021-10-13") OR
       (PS.DataFine BETWEEN "2021-10-08" AND "2021-10-13"))
ORDER BY PS.DataInizio;

-- -----------------------------------------------------------------------------

/* Dato l'Hotel Overlook e il periodo di permanenza DataInizio = 2022-01-08 e 
DataFine = 2022-01-13 e trovare tutte le stanze non prenotate per quel periodo 
nell'hotel dato. */

SELECT S.IdStanza
FROM Stanza S 
WHERE S.NomeHotel = "Hotel Overlook" AND
      S.ViaHotel = "Via Cavour 333" AND
      S.CittaHotel = "Torino" AND
      S.IdStanza NOT IN 
                       (SELECT PS.Stanza
                        FROM PrenotazioneStanza PS
                        WHERE PS.NomeHotel = "Hotel Overlook" AND
                        PS.ViaHotel = "Via Cavour 333" AND
                        PS.CittaHotel = "Torino" AND
                        ((PS.DataInizio BETWEEN "2021-10-08" AND "2021-10-13") OR
                        (PS.DataFine BETWEEN "2021-10-08" AND "2021-10-13")));

-- -----------------------------------------------------------------------------

/* Dato l'anno 2021, stampare per ogni mese la somma degli importi pagati dai 
clienti in quel mese e il numero di fatture emesse. */

SELECT MONTHNAME(FP.Data) as Mese, sum(FP.Totale) as ImportiPagati, 
       count(*) as NumeroFattureEmesse 
FROM FatturaPrenotazione FP 
WHERE YEAR(FP.Data) = "2021" 
GROUP BY MONTHNAME(FP.Data)
ORDER BY MONTHNAME(FP.Data);


-- -----------------------------------------------------------------------------

/* Dato l'anno, stampare per ogni mese il numero di persone che hanno alloggiato
in ciascun hotel in quel mese */

SELECT MONTHNAME(PS.DataFine), PS.NomeHotel, PS.ViaHotel, 
       PS.CittaHotel, count(*) as NumeroOspiti
FROM Ospite O
JOIN PrenotazioneStanza PS
  ON O.PrenotazioneStanza = PS.IdPrenotazione
JOIN Stanza S
  ON PS.Stanza = S.IdStanza AND 
     PS.NomeHotel = S.NomeHotel AND
     PS.ViaHotel = S.ViaHotel AND 
     PS.CittaHotel = PS.CittaHotel
WHERE YEAR(PS.DataFine) = "2021" 
AND S.Nome IS NULL
GROUP BY MONTHNAME(PS.DataFine), PS.NomeHotel, PS.ViaHotel, PS.CittaHotel;

-- -----------------------------------------------------------------------------

/* Dato il codice di prenotazione 2594469299 stampare le informazioni di tutte le 
persone che sono stati ospitati nella stanza senza aver prenotato a loro nome e 
per ognuna di esse il codice della relativa prenotazione */

SELECT PS.IdPrenotazione, P.CF CF, P.Nome Nome, P.Cognome Cognome, 
       P.Mail Mail, P.Telefono Telefono, P.DataNascita DataNascita
FROM PrenotazioneStanza PS
JOIN Ospite O
  ON IdPrenotazione = PrenotazioneStanza
JOIN Persona P
  ON O.Persona = P.CF
WHERE IdPrenotazione = "2594469299" AND
      PS.Persona IS NOT NULL AND
O.Persona <> PS.Persona;

-- -----------------------------------------------------------------------------

/* Stampare il codice e il nominativo di tutte le prenotazioni ancora non pagate. */

SELECT PS.IdPrenotazione, COALESCE(PS.Persona, PS.Societa) as Nominativo
FROM PrenotazioneStanza PS
LEFT JOIN FatturaPrenotazione FP
ON PS.IdPrenotazione = FP.PrenotazioneStanza
WHERE FP.IdFattura IS NULL;


SELECT PS.IdPrenotazione, COALESCE(PS.Persona, PS.Societa) as Nominativo
FROM PrenotazioneStanza PS
WHERE PS.IdPrenotazione NOT IN (SELECT FP.PrenotazioneStanza
                                FROM FatturaPrenotazione FP);

-- -----------------------------------------------------------------------------

/* Stampare per ogni fattura di prenotazione il codice, il costo di prenotazione e 
la data del pagamento. */

SELECT IdFattura, Totale, Data as "Data pagamento" FROM FatturaPrenotazione;


-- -----------------------------------------------------------------------------

/* Stampare le informazioni di tutti gli hotel e dei servizi offerti da ciascun hotel. */

SELECT H.Nome, H.Via, H.Citta, S.Nome 
FROM Hotel H 
JOIN Servizio S 
 ON H.Nome = S.NomeHotel AND 
    H.Via = S.ViaHotel AND 
    H.Citta = S.CittaHotel;

-- -----------------------------------------------------------------------------

/* Stampare il nome, cognome e telefono di tutte le persone che hanno fatto uso di
almeno un servizio, e il nome del servizio da loro utilizzato con la data 
d’utilizzo. */

SELECT P.Nome Nome, P.Cognome Cognome, 
        P.Telefono Telefono, US.NomeServizio, US.Data Data
FROM UsoServizio US
JOIN Persona P
ON US.Persona = P.CF;

-- -----------------------------------------------------------------------------

/* Stampare il nome, cognome e telefono di tutte le persone che hanno partecipato a
un convegno e prenotato un camera nell’hotel dove il convegno è stato 
presentato. */

SELECT P.Nome Nome, P.Cognome Cognome, P.Telefono Telefono
FROM Stanza S
JOIN PrenotazioneStanza PS
  ON PS.Stanza = S.IdStanza AND 
     PS.NomeHotel = S.NomeHotel AND 
     PS.ViaHotel = S.ViaHotel AND 
     PS.CittaHotel = S.CittaHotel
JOIN Ospite O
  ON O.PrenotazioneStanza = PS.IdPrenotazione
JOIN Persona P
  ON P.CF = O.Persona
JOIN PrenotazioneStanza PS1
  ON PS1.Persona = P.CF
JOIN Stanza S1
  ON PS1.Stanza = S1.IdStanza AND 
     PS1.NomeHotel = S1.NomeHotel AND
     PS1.ViaHotel = S1.ViaHotel AND 
     PS1.CittaHotel = S1.CittaHotel
WHERE S.Nome IS NOT NULL AND
      S1.Nome IS NULL AND
      PS.NomeHotel = PS1.NomeHotel AND
      PS.ViaHotel = PS1.ViaHotel AND
      PS.CittaHotel = PS1.CittaHotel;

-- -----------------------------------------------------------------------------

/* Stampare codice fiscale, nome, cognome, numero di telefono di tutte le persone 
che sono stati ospiti della catena alberghiera più di due volte. */

SELECT P.CF, P.Nome Nome, P.Cognome Cognome, P.Telefono Telefono
FROM Persona P
JOIN Ospite O
ON P.CF = O.Persona
GROUP BY P.CF
HAVING count(*) > 2;

-- -----------------------------------------------------------------------------

/* Dato l'anno 2021 e l'Hotel Casino, Corso degli Inglesi 18, Sanremo stampare per 
ogni mese il numero di prenotazioni ricevute e la somma degli importi pagati per
le prenotazioni in quel mese */

SELECT "2021" as Anno , MONTHNAME(PS.DataFine), 
       count(*) NumeroPrenotazioni, sum(FP.Totale) Incasso
FROM PrenotazioneStanza PS
JOIN FatturaPrenotazione FP
ON PS.IdPrenotazione = FP.PrenotazioneStanza
WHERE YEAR(PS.DataFine) = "2021" AND
PS.NomeHotel = "Hotel Casino" AND
PS.ViaHotel = "Corso degli Inglesi 18" AND
PS.CittaHotel = "Sanremo"
GROUP BY MONTHNAME(PS.DataFine);

-- -----------------------------------------------------------------------------

/* Stampare per ogni attività di manutenzione il nome, la citta e la via dell’hotel 
e il numero della stanza in cui si è verificato il guasto, la descrizione del 
guasto, le spese di manutenzione, il tipo di manutenzione e il nome della 
società che ha fornito la manutenzione */

SELECT AM.Stanza, AM.NomeHotel, AM.ViaHotel, AM.CittaHotel, 
       AM.Descrizione, AM.Prezzo, AM.Categoria, S.Nome 
FROM AttivitaManutenzione AM, Societa S 
WHERE AM.Societa = S.PartitaIVA;

-- -----------------------------------------------------------------------------

/* Stampare il numero delle attività di manutenzioni eseguite e il totale delle 
spese per categoria e per hotel in cui vengono eseguite. */

SELECT AM.NomeHotel, AM.ViaHotel, AM.CittaHotel, AM.Categoria, 
       count(*) as "Numero Manutenzioni", 
       sum(AM.Prezzo) as "Totale Spese per Categoria di Manutenzione" 
FROM AttivitaManutenzione AM, Societa S 
WHERE AM.Societa = S.PartitaIVA
GROUP BY AM.NomeHotel, AM.ViaHotel, AM.CittaHotel, AM.Categoria;

-- -----------------------------------------------------------------------------

/* Stampare per ciascun servizio di ciascun hotel il numero di dipendenti afferenti 
a quel servizio e la loro età media. */

SELECT S.Nome, S.NomeHotel, S.ViaHotel, S.CittaHotel, 
       count(*), avg(TIMESTAMPDIFF(YEAR, D.DataNascita, CURDATE())) as EtaMedia
FROM Servizio S
JOIN Dipendente D
  ON D.NomeServizio = S.Nome AND 
     D.NomeHotel = S.NomeHotel AND 
     D.ViaHotel = S.ViaHotel AND 
     D.CittaHotel = S.CittaHotel
GROUP BY S.Nome, S.NomeHotel, S.ViaHotel, S.CittaHotel;

-- -----------------------------------------------------------------------------

/* Per ogni servizio di ogni hotel si vuole sapere lo stipendio medio dei 
dipendenti afferenti a quel servizio, e la somma degli stipendi per ogni 
servizio. */

SELECT S.Nome, S.NomeHotel, S.ViaHotel, S.CittaHotel, 
       avg(D.Stipendio) as "Stipendio Mensile Medio", 
       sum(D.Stipendio) as "Somma Annuale Stipendi"
FROM Servizio S
JOIN Dipendente D
ON D.NomeServizio = S.Nome AND 
   D.NomeHotel = S.NomeHotel AND
   D.ViaHotel = S.ViaHotel AND 
   D.CittaHotel = S.CittaHotel
GROUP BY S.Nome, S.NomeHotel, S.ViaHotel, S.CittaHotel;

-- -----------------------------------------------------------------------------

/* Stampare sulla stessa riga per ogni hotel il numero di manutenzioni per 
categoria eseguite in quell'hotel. */

SELECT AM.NomeHotel, AM.ViaHotel, AM.CittaHotel,
  SUM(CASE WHEN AM.Categoria = "Idraulica" THEN 1 ELSE 0 END) "Manutenzioni Idrauliche",
  SUM(CASE WHEN AM.Categoria = "Elettrica" THEN 1 ELSE 0 END) "Manutenzioni Elettriche",
  SUM(CASE WHEN AM.Categoria = "Pulizia" THEN 1 ELSE 0 END) "Manutenzioni Pulizie",
  SUM(CASE WHEN AM.Categoria = "Edile" THEN 1 ELSE 0 END) "Manutenzioni Edili",
  SUM(CASE WHEN AM.Categoria = "Arredo" THEN 1 ELSE 0 END) "Manutenzioni Arredo"
FROM AttivitaManutenzione AM
GROUP BY AM.NomeHotel, AM.ViaHotel, AM.CittaHotel;

-- -----------------------------------------------------------------------------

/* Stampare sulla stessa riga per ogni hotel il numero di pagamenti 
per tipo di pagamento e l'incasso totale per tutte le fatture di preotazione. */

SELECT PS.NomeHotel,PS.ViaHotel, PS.CittaHotel,
  SUM(CASE WHEN FP.TipoPagamento = "Bonifico" THEN 1 ELSE 0 END) "Numero Pagamenti con Bonifico",
  SUM(CASE WHEN FP.TipoPagamento = "Carta" THEN 1 ELSE 0 END) "Numero Pagamenti con Carta",
  SUM(CASE WHEN FP.TipoPagamento = "Contanti" THEN 1 ELSE 0 END) "Numero Pagamenti con Contanti",
  SUM(FP.Totale) "Incasso Totale"
FROM FatturaPrenotazione FP
JOIN PrenotazioneStanza PS
ON FP.PrenotazioneStanza = PS.IdPrenotazione
GROUP BY PS.NomeHotel, PS.ViaHotel, PS.CittaHotel;

-- -----------------------------------------------------------------------------

/* Le camere dell'hotel sheraton che hanno un numero di prenotazioni sopra la media*/

SELECT PS.Stanza, count(*)
FROM PrenotazioneStanza PS
JOIN Stanza S
  ON PS.Stanza = S.IdStanza AND 
     PS.NomeHotel = S.NomeHotel AND 
     PS.CittaHotel = S.CittaHotel AND 
     PS.ViaHotel = S.ViaHotel
WHERE PS.NomeHotel = "Hotel Sheraton" AND
      PS.ViaHotel = "Via Marsala 20" AND
      PS.CittaHotel = "Roma" AND
      S.Nome IS NULL
GROUP BY PS.Stanza
HAVING count(*) > ALL
( SELECT count(*)/ (SELECT count(*) 
                    FROM Stanza S 
                    WHERE S.Nome IS NULL AND S.NomeHotel = "Hotel Sheraton" 
                                         AND S.ViaHotel = "Via Marsala 20" 
                                         AND S.CittaHotel = "Roma")  
  FROM PrenotazioneStanza PS 
  JOIN Stanza S 
  ON PS.Stanza = S.IdStanza AND  
  PS.NomeHotel = S.NomeHotel AND  
  PS.CittaHotel = S.CittaHotel AND  
  PS.ViaHotel = S.ViaHotel 
  WHERE PS.NomeHotel = "Hotel Sheraton" AND 
  PS.ViaHotel = "Via Marsala 20" AND 
  PS.CittaHotel = "Roma" AND 
  S.Nome IS NULL
);

-- -----------------------------------------------------------------------------

/* Tutti i convegni ordinati per numero di posti prenotati e data, tenuti negli 
hotel diversi dall' hotel casino e che hanno avuto un numero di posti prenotati 
maggiore di almeno uno dei convegni tenuti nell'hotel casino */

SELECT PS.NomeHotel, PS.DataInizio, PS.NumPosti, C.Nome
FROM PrenotazioneStanza PS
JOIN Stanza S 
ON PS.Stanza = S.IdStanza AND  
   PS.NomeHotel = S.NomeHotel AND  
   PS.CittaHotel = S.CittaHotel AND  
   PS.ViaHotel = S.ViaHotel 
JOIN Convegno C
ON C.Stanza = PS.Stanza AND
   C.NomeHotel = PS.NomeHotel AND  
   C.CittaHotel = PS.CittaHotel AND  
   C.ViaHotel = PS.ViaHotel AND
   C.Data = PS.DataInizio
WHERE S.Nome IS NOT NULL AND
      PS.NomeHotel <> "Hotel Casino" AND
      PS.ViaHotel <> "Corso degli Inglesi 18" AND
      PS.CittaHotel <> "Sanremo" AND
      PS.NumPosti > ANY 

( SELECT PS.NumPosti
  FROM PrenotazioneStanza PS
  JOIN Stanza S 
  ON PS.Stanza = S.IdStanza AND 
  PS.NomeHotel = S.NomeHotel AND  
  PS.CittaHotel = S.CittaHotel AND  
  PS.ViaHotel = S.ViaHotel 
  WHERE S.Nome is not null AND
  PS.NomeHotel = "Hotel Casino" AND
  PS.ViaHotel = "Corso degli Inglesi 18" AND
  PS.CittaHotel = "Sanremo" )
  
ORDER BY PS.NumPosti, PS.DataInizio;

-- -----------------------------------------------------------------------------

/* Tutte le persone che sono state più di due volte clienti della catena alberghiera */

SELECT SQL_NO_CACHE P.*
FROM Persona P
WHERE P.CF IN
      (SELECT O.Persona
      FROM Ospite O
      GROUP BY O.Persona
      HAVING count(*) > 2);
-- -----------------------------------------------------------------------------

/* Stampare per ogni servizio di ogni hotel e per ogni mese la somma delle spese 
per l'acquisto dei prodotti di quel servizio. */

SELECT MONTHNAME(FO.Data), S.Nome Servizio, S.NomeHotel, 
       S.ViaHotel, S.CittaHotel, sum(O.Prezzo) "Spese per Servizio"
FROM Servizio S
JOIN FatturaOrdine FO
ON FO.NomeServizio = S.Nome AND 
   FO.NomeHotel = S.NomeHotel AND 
   FO.ViaHotel = S.ViaHotel AND 
   FO.CittaHotel = S.CittaHotel
JOIN Ordine O
ON O.Fattura = FO.IdFattura
GROUP BY MONTHNAME(FO.Data), S.Nome, 
         S.NomeHotel, S.ViaHotel, S.CittaHotel;
