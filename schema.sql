-- =============================================================================
--
--                            HOTEL STATISTICS
--
-- Authors: Simone Caruso, Gabriele Biscetti
--
-- =============================================================================

DROP DATABASE IF EXISTS HotelStatistics;

CREATE DATABASE HotelStatistics DEFAULT CHARSET=utf8mb4;
USE HotelStatistics;

--
-- Table structure for table `Hotel`
--

CREATE TABLE Hotel
(
  Nome VARCHAR(50),
  Via VARCHAR(50),
  Citta VARCHAR(30),
  Stelle TINYINT UNSIGNED CHECK (STELLE > 0 AND STELLE <= 5),
  Telefono VARCHAR(15) NOT NULL,
  
  PRIMARY KEY (Nome,Via,Citta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Persona`
--

CREATE TABLE Persona
(
  CF CHAR(16) PRIMARY KEY,
  Nome VARCHAR(30),
  Cognome VARCHAR(30),
  Mail VARCHAR(100) NOT NULL,
  Telefono VARCHAR(15) NOT NULL,
  DataNascita DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Societa`
--

CREATE TABLE Societa
(
  PartitaIVA CHAR(11) PRIMARY KEY,
  Nome VARCHAR(50),
  Mail VARCHAR(100) NOT NULL,
  Telefono VARCHAR(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Prodotto`
--

CREATE TABLE Prodotto
(
  IdProdotto VARCHAR(15) PRIMARY KEY,
  Nome VARCHAR(50),
  Marca VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Stanza`
--

CREATE TABLE Stanza
(
  IdStanza INT UNSIGNED, 
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),
  Prezzo DECIMAL(7,2),
  NumPosti INT UNSIGNED,
  Nome VARCHAR(30),
  
  PRIMARY KEY (IdStanza, NomeHotel, ViaHotel, CittaHotel),
  FOREIGN KEY (NomeHotel, ViaHotel, CittaHotel) REFERENCES Hotel(Nome, Via, Citta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Servizio`
--

CREATE TABLE Servizio
(
  Nome VARCHAR(30),
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),

  PRIMARY KEY (Nome, NomeHotel, ViaHotel, CittaHotel),
  FOREIGN KEY (NomeHotel, ViaHotel, CittaHotel) REFERENCES Hotel(Nome, Via, Citta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `FatturaOrdine`
--

CREATE TABLE FatturaOrdine
(
  IdFattura CHAR(14),
  Data DATE,
  Totale DECIMAL(8,2),
  PezziTotali INT UNSIGNED,
  NomeServizio VARCHAR(30),
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),

  PRIMARY KEY (IdFattura),
  FOREIGN KEY (NomeServizio, NomeHotel, ViaHotel, CittaHotel)
  REFERENCES Servizio(Nome, NomeHotel, ViaHotel, CittaHotel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Ordine`
--

CREATE TABLE Ordine
(
  Fattura CHAR(14),
  Prodotto VARCHAR(15),
  Quantita INT UNSIGNED,
  Prezzo DECIMAL (7,2),

  PRIMARY KEY (Fattura,Prodotto),
  FOREIGN KEY (Fattura) REFERENCES FatturaOrdine(IdFattura),
  FOREIGN KEY (Prodotto) REFERENCES Prodotto(IdProdotto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `AttivitaManutenzione`
--

CREATE TABLE AttivitaManutenzione
(
  Stanza INT UNSIGNED,
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),
  Data DATE,
  Categoria VARCHAR(50) CHECK (Categoria IN ('Idraulica','Elettrica','Pulizia','Edile','Arredo')),
  Prezzo DECIMAL(6,2),
  Descrizione TEXT,
  Societa CHAR(11),

  PRIMARY KEY (Stanza, NomeHotel, CittaHotel, ViaHotel, Data, Categoria),
  FOREIGN KEY (Societa) REFERENCES Societa(PartitaIVA),
  FOREIGN KEY (Stanza, NomeHotel, ViaHotel, CittaHotel) REFERENCES Stanza(IdStanza, NomeHotel, ViaHotel, CittaHotel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Convegno`
--

CREATE TABLE Convegno
(
  Data DATE,
  Nome VARCHAR(100),
  Stanza INT UNSIGNED,
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),
 
  PRIMARY KEY (Data,Nome), 
  FOREIGN KEY (Stanza, NomeHotel, ViaHotel, CittaHotel) REFERENCES Stanza(IdStanza,NomeHotel, ViaHotel, CittaHotel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Dipendente`
--

CREATE TABLE Dipendente
(
  CF CHAR(16) PRIMARY KEY,
  Nome VARCHAR(30),
  Cognome VARCHAR(30),
  DataNascita DATE,
  Stipendio DECIMAL(6,2),
  DataAssunzione DATE,
  NomeServizio VARCHAR(50),
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),

  FOREIGN KEY (NomeServizio, NomeHotel, ViaHotel, CittaHotel) REFERENCES Servizio(Nome, NomeHotel, ViaHotel, CittaHotel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `PrenotazioneStanza`
--

CREATE TABLE PrenotazioneStanza
(
  IdPrenotazione CHAR(10) PRIMARY KEY,
  DataInizio DATE,
  DataFine DATE,
  NumPosti INT UNSIGNED,
  Stanza INT UNSIGNED,
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),
  Societa CHAR(11),
  Persona CHAR(16),

  FOREIGN KEY (Stanza, NomeHotel, ViaHotel, CittaHotel) REFERENCES Stanza(IdStanza, NomeHotel, ViaHotel, CittaHotel),
  FOREIGN KEY (Societa) REFERENCES Societa(PartitaIVA),
  FOREIGN KEY (Persona) REFERENCES Persona(CF)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `FatturaPrenotazione`
--

CREATE TABLE FatturaPrenotazione
(
  IdFattura CHAR(14) PRIMARY KEY,
  Totale DECIMAL(8,2),
  Data DATE,
  TipoPagamento VARCHAR(50) CHECK (TipoPagamento IN ('Contanti','Carta','Bonifico')),
  PrenotazioneStanza CHAR(10) REFERENCES PrenotazioneStanza(IdPrenotazione)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `Ospite`
--

CREATE TABLE Ospite
(
  PrenotazioneStanza CHAR(10),
  Persona CHAR(16),

  PRIMARY KEY (PrenotazioneStanza, Persona),
  FOREIGN KEY (PrenotazioneStanza) REFERENCES PrenotazioneStanza(IdPrenotazione),
  FOREIGN KEY (Persona) REFERENCES Persona(CF)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `UsoServizio`
--

CREATE TABLE UsoServizio
(
  NomeServizio VARCHAR(30),
  Persona CHAR(16),
  NomeHotel VARCHAR(50),
  ViaHotel VARCHAR(50),
  CittaHotel VARCHAR(30),
  Data DATE,

  PRIMARY KEY (NomeServizio,Persona, NomeHotel, ViaHotel, CittaHotel,Data),
  FOREIGN KEY (NomeServizio, NomeHotel, ViaHotel, CittaHotel) REFERENCES Servizio(Nome, NomeHotel, ViaHotel, CittaHotel),
  FOREIGN KEY (Persona) REFERENCES Persona(CF)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
