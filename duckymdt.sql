USE `essentialmode`;

ALTER TABLE `users`
	ADD COLUMN `riskiness` INT(11) NULL DEFAULT '0'
;

CREATE TABLE `mdt_profile` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`mugshot_url` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=22
;

CREATE TABLE IF NOT EXISTS `fine_types` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`label` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`amount` INT(11) NULL DEFAULT NULL,
	`jailtime` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_bin'
ENGINE=InnoDB
AUTO_INCREMENT=115
;

CREATE TABLE `mdt_fines` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`charge` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`amount` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=95
;

CREATE TABLE `mdt_notes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`name` VARCHAR(255) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
	`note` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`agent` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`date` VARCHAR(255) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=29
;


INSERT IGNORE INTO `fine_types` (`label`, `amount`, `jailtime`) VALUES
	('Abusive use of horn', 30, 1),
	('Evade continuous line', 50, 2),
	('Central Bank Robbery', 20000, 10);


