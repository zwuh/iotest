-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 02, 2014 at 05:05 PM
-- Server version: 5.5.38
-- PHP Version: 5.3.10-1ubuntu3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `iotest`
--

-- --------------------------------------------------------

--
-- Table structure for table `blocksize`
--

CREATE TABLE IF NOT EXISTS `blocksize` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `scenario` int(3) unsigned NOT NULL,
  `fs` int(3) unsigned NOT NULL,
  `date` date NOT NULL,
  `n_threads` int(3) unsigned NOT NULL,
  `n_jobs` int(5) unsigned NOT NULL,
  `job_size` int(6) unsigned NOT NULL COMMENT 'bytes',
  `block_size` int(6) unsigned NOT NULL,
  `rw` enum('r','w') NOT NULL,
  `flag` enum('d','s','def','ds') NOT NULL,
  `cpu` double NOT NULL,
  `throughput` double NOT NULL,
  `elapsed` double NOT NULL,
  `npkt` int(10) unsigned NOT NULL,
  `transferred` int(10) unsigned NOT NULL,
  `bytes_clean` int(10) unsigned NOT NULL,
  `error` int(5) unsigned NOT NULL DEFAULT '0' COMMENT 'non zero if serviced < n_jobs',
  PRIMARY KEY (`id`),
  KEY `scenario` (`scenario`),
  KEY `n_threads` (`n_threads`),
  KEY `fs` (`fs`),
  KEY `rw` (`rw`),
  KEY `flag` (`flag`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='block-size test results' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `file`
--

CREATE TABLE IF NOT EXISTS `file` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `scenario` int(3) unsigned NOT NULL,
  `fs` int(3) unsigned NOT NULL,
  `date` date NOT NULL,
  `n_threads` int(3) unsigned NOT NULL,
  `n_jobs` int(5) unsigned NOT NULL,
  `job_size` int(6) unsigned NOT NULL COMMENT 'bytes',
  `block_size` int(6) unsigned NOT NULL,
  `rw` enum('r','w') NOT NULL,
  `flag` enum('d','s','def','ds') NOT NULL,
  `cpu` double NOT NULL,
  `throughput` double NOT NULL,
  `elapsed` double NOT NULL,
  `npkt` int(10) unsigned NOT NULL,
  `transferred` int(10) unsigned NOT NULL,
  `bytes_clean` int(10) unsigned NOT NULL,
  `error` int(5) unsigned NOT NULL DEFAULT '0' COMMENT 'non zero if serviced < n_jobs',
  PRIMARY KEY (`id`),
  KEY `scenario` (`scenario`),
  KEY `n_threads` (`n_threads`),
  KEY `fs` (`fs`),
  KEY `rw` (`rw`),
  KEY `flag` (`flag`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='file test results (not block-size test)' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `macro`
--

CREATE TABLE IF NOT EXISTS `macro` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `scenario` int(3) unsigned NOT NULL,
  `fs` int(3) unsigned NOT NULL,
  `bench` int(3) NOT NULL,
  `conf` int(3) NOT NULL COMMENT 'macrobenchmak configuration',
  `date` date NOT NULL,
  `throughput` double NOT NULL,
  `elapsed` double NOT NULL,
  PRIMARY KEY (`id`),
  KEY `scenario` (`scenario`),
  KEY `fs` (`fs`),
  KEY `bench` (`bench`),
  KEY `fk_macro_benchconf` (`conf`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='macrobenchmark results' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `macrobench`
--

CREATE TABLE IF NOT EXISTS `macrobench` (
  `id` int(3) NOT NULL,
  `name` varchar(32) NOT NULL,
  `remark` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Macrobenchmarks';

-- --------------------------------------------------------

--
-- Table structure for table `macroconf`
--

CREATE TABLE IF NOT EXISTS `macroconf` (
  `id` int(3) NOT NULL,
  `bench` int(3) NOT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `conf` text,
  PRIMARY KEY (`id`),
  KEY `fk_macroconf_bench` (`bench`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='macrobenchmark configurations';

-- --------------------------------------------------------

--
-- Table structure for table `metadata`
--

CREATE TABLE IF NOT EXISTS `metadata` (
  `id` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `scenario` int(3) unsigned NOT NULL,
  `fs` int(3) unsigned NOT NULL,
  `date` date NOT NULL,
  `op` enum('mkdir','touch','ls','unlink','rmdir') NOT NULL,
  `n_jobs` int(5) unsigned NOT NULL,
  `elapsed` double NOT NULL,
  `npkt` int(10) unsigned NOT NULL,
  `transferred` int(10) unsigned NOT NULL,
  `cpu` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scenario` (`scenario`),
  KEY `fs` (`fs`),
  KEY `op` (`op`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='Metadata test results' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `scenario`
--

CREATE TABLE IF NOT EXISTS `scenario` (
  `id` int(3) unsigned NOT NULL,
  `delay` int(4) unsigned NOT NULL DEFAULT '0',
  `bandwidth` int(6) unsigned NOT NULL,
  `loss` double NOT NULL,
  `jitter` int(4) NOT NULL DEFAULT '0',
  `clean` enum('yes','no') NOT NULL DEFAULT 'no',
  `remark` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Experimental setup';

-- --------------------------------------------------------

--
-- Table structure for table `target`
--

CREATE TABLE IF NOT EXISTS `target` (
  `id` int(3) unsigned NOT NULL,
  `name` varchar(32) NOT NULL,
  `remark` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Storage Targets';

--
-- Constraints for dumped tables
--

--
-- Constraints for table `blocksize`
--
ALTER TABLE `blocksize`
  ADD CONSTRAINT `fk_bs_scenario` FOREIGN KEY (`scenario`) REFERENCES `scenario` (`id`),
  ADD CONSTRAINT `fk_bs_target` FOREIGN KEY (`fs`) REFERENCES `target` (`id`);

--
-- Constraints for table `file`
--
ALTER TABLE `file`
  ADD CONSTRAINT `fk_scenario` FOREIGN KEY (`scenario`) REFERENCES `scenario` (`id`),
  ADD CONSTRAINT `fk_target` FOREIGN KEY (`fs`) REFERENCES `target` (`id`);

--
-- Constraints for table `macro`
--
ALTER TABLE `macro`
  ADD CONSTRAINT `fk_macro_bench` FOREIGN KEY (`bench`) REFERENCES `macrobench` (`id`),
  ADD CONSTRAINT `fk_macro_benchconf` FOREIGN KEY (`conf`) REFERENCES `macroconf` (`id`),
  ADD CONSTRAINT `fk_macro_scenario` FOREIGN KEY (`scenario`) REFERENCES `scenario` (`id`),
  ADD CONSTRAINT `fk_macro_target` FOREIGN KEY (`fs`) REFERENCES `target` (`id`);

--
-- Constraints for table `macroconf`
--
ALTER TABLE `macroconf`
  ADD CONSTRAINT `fk_macroconf_bench` FOREIGN KEY (`bench`) REFERENCES `macrobench` (`id`);

--
-- Constraints for table `metadata`
--
ALTER TABLE `metadata`
  ADD CONSTRAINT `fk_meta_scenario` FOREIGN KEY (`scenario`) REFERENCES `scenario` (`id`),
  ADD CONSTRAINT `fk_meta_target` FOREIGN KEY (`fs`) REFERENCES `target` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
