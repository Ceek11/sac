-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : ven. 06 oct. 2023 à 19:27
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `template`
--

-- --------------------------------------------------------

--
-- Structure de la table `owned_bag`
--

CREATE TABLE `owned_bag` (
  `id` int(11) NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `item` longtext NOT NULL DEFAULT '{}',
  `onfloor` tinyint(1) NOT NULL,
  `clotheSac` varchar(5) DEFAULT NULL,
  `coords` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `owned_bag`
--

INSERT INTO `owned_bag` (`id`, `identifier`, `item`, `onfloor`, `clotheSac`, `coords`) VALUES
(9, 'a023603b196b40b4a683b77429127786974fefc1', '[{\"quantity\":5,\"name\":\"bag\",\"label\":\"Sac\"}]', 0, '45', '');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `owned_bag`
--
ALTER TABLE `owned_bag`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `owned_bag`
--
ALTER TABLE `owned_bag`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
