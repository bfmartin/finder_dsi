DROP TABLE IF EXISTS `dsi`;

CREATE TABLE `dsi` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `pubdate` date NOT NULL,
  `title` varchar(400) NOT NULL,
  `chars` varchar(100) DEFAULT NULL,
  `keywords` varchar(300) DEFAULT NULL,
  `dialog` text DEFAULT NULL,
  `title_stem` varchar(400) NOT NULL,
  `keywords_stem` varchar(300) DEFAULT NULL,
  `dialog_stem` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `dsiidx` (`title_stem`,`chars`,`keywords_stem`,`dialog_stem`)
);

DROP TABLE IF EXISTS `dsilog`;

CREATE TABLE `dsilog` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `sdate` datetime NOT NULL,
  `words` text NOT NULL,
  `ipaddr` varchar(20) NOT NULL,
  `hits` smallint NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `dsitopsearches`;

create table `dsitopsearches`(
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `words` text NOT NULL,
  `occurrences` int unsigned NOT NULL,
  PRIMARY KEY (`id`)
);

