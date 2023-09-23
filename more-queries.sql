/*
NOTA:
Le query proposte fanno riferimento al capitolo 16 del libro learning sql.
Vengono utilizzate le analytic functions che permettono di definire data windows
tramite la clausola over (). 
*/


/*
Stampare per ogni mese del 2021 la spesa mensile per l'acquisto dei prodotti per
il servizio di Spa dell'Hotel Sheraton di Roma e la spesa totale corrente da 
inizio anno fino al mese corrente incluso.
*/

SELECT month(FO.Data) Mese, sum(FO.Totale) Totale,
sum(sum(FO.Totale)) 
    over (ORDER BY month(FO.Data)
          rows unbounded preceding) "Spesa totale da inizio 2021"
FROM FatturaOrdine FO
JOIN Ordine O
ON FO.IdFattura = O.Fattura
WHERE FO.NomeServizio = "Spa" AND
      FO.NomeHotel = "Hotel Sheraton" AND
      FO.ViaHotel = "Via Marsala 20" AND
      FO.CittaHotel = "Roma" AND
      YEAR(FO.Data) = "2021"
GROUP BY month(FO.Data)
ORDER BY month(FO.Data);

/*
Stampare per ogni mese del 2021 gli incassi per le prenotazioni delle stanze 
dell'Hotel Casino di Sanremo e la media dell'incasso calcolata per ogni mese 
rispetto al mese precedente, al mese corrente e al mese successivo.
*/

SELECT month(FP.Data) Mese, sum(FP.Totale) Totale,
round(avg(sum(FP.Totale)) 
  over (ORDER BY month(FP.Data) rows between 1 preceding and 1 following),2) rolling_avg
FROM FatturaPrenotazione FP
JOIN PrenotazioneStanza PS
ON FP.PrenotazioneStanza = PS.IdPrenotazione
WHERE PS.NomeHotel = "Hotel Casino" AND
                       PS.ViaHotel = "Corso degli Inglesi 18" AND
                       PS.CittaHotel = "Sanremo" AND
                       YEAR(FP.Data) = "2021"
GROUP BY month(FP.Data)
ORDER BY month(FP.Data);


/*
Stampare per ogni mese del 2021 il totale degli incassi mensili per le 
prenotazioni delle stanze di tutti gli hotel, l'incasso mensile di ciascun hotel
e la percentuale dell'incasso mensile di ogni hotel rispetto all'incasso mensile
totale di tutti gli hotel.
*/

SELECT monthname(FP.Data) Mese, sum(FP.Totale) "Incasso Mensile",
sum(CASE WHEN (PS.NomeHotel = "Hotel Sheraton" AND 
               PS.ViaHotel = "Via Marsala 20" AND 
               PS.CittaHotel = "Roma") 
    THEN FP.Totale ELSE 0 END) "Incasso Sheraton",
round(sum(CASE WHEN (PS.NomeHotel = "Hotel Sheraton" AND 
                     PS.ViaHotel = "Via Marsala 20" AND 
                     PS.CittaHotel = "Roma") 
THEN FP.Totale ELSE 0 END)/sum(FP.Totale) * 100, 2) "Percentuale Sheraton",
sum(CASE WHEN (PS.NomeHotel = "Hotel Casino" AND PS.ViaHotel = "Corso degli Inglesi 18" AND PS.CittaHotel = "Sanremo") 
THEN FP.Totale ELSE 0 END) "Incasso Casino",
round(sum(CASE WHEN (PS.NomeHotel = "Hotel Casino" AND PS.ViaHotel = "Corso degli Inglesi 18" AND PS.CittaHotel = "Sanremo") 
THEN FP.Totale ELSE 0 END)/sum(FP.Totale) * 100, 2) "Percentuale Casino",
sum(CASE WHEN (PS.NomeHotel = "Hotel Overlook" AND PS.ViaHotel = "Via Cavour 333" AND PS.CittaHotel = "Torino") 
THEN FP.Totale ELSE 0 END) "Incasso Overlook",
round(sum(CASE WHEN (PS.NomeHotel = "Hotel Overlook" AND PS.ViaHotel = "Via Cavour 333" AND PS.CittaHotel = "Torino") 
THEN FP.Totale ELSE 0 END)/sum(FP.Totale) * 100, 2) "Percentuale Overlook"
FROM FatturaPrenotazione FP
JOIN PrenotazioneStanza PS
ON FP.PrenotazioneStanza = PS.IdPrenotazione
WHERE YEAR(FP.Data) = "2021"
GROUP BY monthname(FP.Data);

/*
Stampare per l'anno 2021 la Data dell'acquisto mensile, il Nome, la Marca e il 
Prezzo di una singola unità del prodotto con codice 1197712992488 rispetto 
agli acquisti effettuati dal servizio del Casinò dell'Hotel Casino di Sanremo.
*/

SELECT FO.Data, P.Nome, P.Marca, (O.Prezzo/O.Quantita) "Prezzo Prodotto"
FROM FatturaOrdine FO
JOIN Ordine O
ON O.Fattura = FO.IdFattura
JOIN Prodotto P
ON P.IdProdotto = O.Prodotto
WHERE (FO.NomeServizio = "Casino" AND FO.NomeHotel = "Hotel Casino" AND 
FO.ViaHotel = "Corso degli Inglesi 18" AND FO.CittaHotel = "Sanremo" 
AND P.IdProdotto = "1197712992488" AND YEAR(FO.Data) = "2021") 
ORDER BY FO.Data;

/*
Stampare per l'anno 2021 la Data dell'acquisto mensile, il Nome, la Marca, il 
Prezzo di una singola unità del prodotto con codice 1197712992488 rispetto 
agli acquisti effettuati dal servizio del Casinò dell'Hotel Casino di Sanremo, e
stampare per ogni mese la variazione in percentuale del prezzo di una singola 
unita di prodotto  rispetto al mese precedente.
*/

SELECT FO.Data, P.Nome, P.Marca, (O.Prezzo/O.Quantita) "Prezzo Prodotto",
round(((O.Prezzo/O.Quantita) - lag((O.Prezzo/O.Quantita),1) over (ORDER BY FO.Data)) /
         lag((O.Prezzo/O.Quantita),1) over (ORDER BY FO.Data) * 100, 2) "Variazione in percentuale"
FROM FatturaOrdine FO
JOIN Ordine O
ON O.Fattura = FO.IdFattura
JOIN Prodotto P
ON P.IdProdotto = O.Prodotto
WHERE (FO.NomeServizio = "Casino" AND 
       FO.NomeHotel = "Hotel Casino" AND 
       FO.ViaHotel = "Corso degli Inglesi 18" AND 
       FO.CittaHotel = "Sanremo" AND 
       P.IdProdotto = "1197712992488" AND 
       YEAR(FO.Data) = "2021") 
ORDER BY FO.Data;
