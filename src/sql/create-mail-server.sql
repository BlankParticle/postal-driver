CREATE TABLE `clicks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11),
  `link_id` int(11),
  `ip_address` varchar(255),
  `country` varchar(255),
  `city` varchar(255),
  `user_agent` varchar(255),
  `timestamp` decimal(18,6),
  PRIMARY KEY (`id`)
);

CREATE TABLE `deliveries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11),
  `status` varchar(255),
  `code` int(11),
  `output` varchar(512),
  `details` varchar(512),
  `sent_with_ssl` tinyint DEFAULT 0,
  `log_id` varchar(100),
  `timestamp` decimal(18,6),
  `time` decimal(8,2),
  PRIMARY KEY (`id`)
);

CREATE TABLE `links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11),
  `token` varchar(255),
  `hash` varchar(255),
  `url` text,
  `timestamp` decimal(18,6),
  PRIMARY KEY (`id`)
);

CREATE TABLE `live_stats` (
  `type` varchar(20) NOT NULL,
  `minute` int(11) NOT NULL,
  `count` int(11),
  `timestamp` decimal(18,6)
);

CREATE TABLE `loads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11),
  `ip_address` varchar(255),
  `country` varchar(255),
  `city` varchar(255),
  `user_agent` varchar(255),
  `timestamp` decimal(18,6),
  PRIMARY KEY (`id`)
);

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255),
  `scope` varchar(10),
  `rcpt_to` varchar(255),
  `mail_from` varchar(255),
  `subject` varchar(255),
  `message_id` varchar(255),
  `timestamp` decimal(18,6),
  `route_id` int(11),
  `domain_id` int(11),
  `credential_id` int(11),
  `status` varchar(255),
  `held` tinyint DEFAULT 0,
  `size` varchar(255),
  `last_delivery_attempt` decimal(18,6),
  `raw_table` varchar(255),
  `raw_body_id` int(11),
  `raw_headers_id` int(11),
  `inspected` tinyint DEFAULT 0,
  `spam` tinyint DEFAULT 0,
  `spam_score` decimal(8,2) DEFAULT '0.00',
  `threat` tinyint DEFAULT 0,
  `threat_details` varchar(255),
  `bounce` tinyint DEFAULT 0,
  `bounce_for_id` int(11) DEFAULT 0,
  `tag` varchar(255),
  `loaded` decimal(18,6),
  `clicked` decimal(18,6),
  `received_with_ssl` tinyint,
  `hold_expiry` decimal(18,6),
  `tracked_links` int(11) DEFAULT 0,
  `tracked_images` int(11) DEFAULT 0,
  `parsed` tinyint DEFAULT 0,
  `endpoint_id` int(11),
  `endpoint_type` varchar(255),
  PRIMARY KEY (`id`)
);

CREATE TABLE `migrations` (
  `version` int(11) NOT NULL
);

CREATE TABLE `raw_message_sizes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(255),
  `size` bigint(20),
  PRIMARY KEY (`id`)
);

CREATE TABLE `spam_checks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11),
  `score` decimal(8,2),
  `code` varchar(255),
  `description` varchar(255),
  PRIMARY KEY (`id`)
);

CREATE TABLE `stats_daily` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` int(11),
  `incoming` bigint(20),
  `outgoing` bigint(20),
  `spam` bigint(20),
  `bounces` bigint(20),
  `held` bigint(20),
  CONSTRAINT `on_time` UNIQUE(`time`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `stats_hourly` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` int(11),
  `incoming` bigint(20),
  `outgoing` bigint(20),
  `spam` bigint(20),
  `bounces` bigint(20),
  `held` bigint(20),
  CONSTRAINT `on_time` UNIQUE(`time`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `stats_monthly` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` int(11),
  `incoming` bigint(20),
  `outgoing` bigint(20),
  `spam` bigint(20),
  `bounces` bigint(20),
  `held` bigint(20),
  CONSTRAINT `on_time` UNIQUE(`time`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `stats_yearly` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` int(11),
  `incoming` bigint(20),
  `outgoing` bigint(20),
  `spam` bigint(20),
  `bounces` bigint(20),
  `held` bigint(20),
  CONSTRAINT `on_time` UNIQUE(`time`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `suppressions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255),
  `address` varchar(255),
  `reason` varchar(255),
  `timestamp` decimal(18,6),
  `keep_until` decimal(18,6),
  PRIMARY KEY (`id`)
);

CREATE TABLE `webhook_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255),
  `event` varchar(255),
  `attempt` int(11),
  `timestamp` decimal(18,6),
  `status_code` int(1),
  `body` text,
  `payload` text,
  `will_retry` tinyint,
  `url` varchar(255),
  `webhook_id` int(11),
  PRIMARY KEY (`id`)
);

CREATE INDEX `on_message_id` ON `clicks` (`message_id`);
CREATE INDEX `on_link_id` ON `clicks` (`link_id`);
CREATE INDEX `on_message_id` ON `deliveries` (`message_id`);
CREATE INDEX `on_message_id` ON `links` (`message_id`);
CREATE INDEX `on_token` ON `links` (`token`);
CREATE INDEX `on_message_id` ON `loads` (`message_id`);
CREATE INDEX `on_message_id` ON `messages` (`message_id`);
CREATE INDEX `on_token` ON `messages` (`token`);
CREATE INDEX `on_bounce_for_id` ON `messages` (`bounce_for_id`);
CREATE INDEX `on_held` ON `messages` (`held`);
CREATE INDEX `on_scope_and_status` ON `messages` (`scope`,`spam`,`status`,`timestamp`);
CREATE INDEX `on_scope_and_tag` ON `messages` (`scope`,`spam`,`tag`,`timestamp`);
CREATE INDEX `on_scope_and_spam` ON `messages` (`scope`,`spam`,`timestamp`);
CREATE INDEX `on_scope_and_thr_status` ON `messages` (`scope`,`threat`,`status`,`timestamp`);
CREATE INDEX `on_scope_and_threat` ON `messages` (`scope`,`threat`,`timestamp`);
CREATE INDEX `on_rcpt_to` ON `messages` (`rcpt_to`,`timestamp`);
CREATE INDEX `on_mail_from` ON `messages` (`mail_from`,`timestamp`);
CREATE INDEX `on_raw_table` ON `messages` (`raw_table`);
CREATE INDEX `on_status` ON `messages` (`status`);
CREATE INDEX `on_table_name` ON `raw_message_sizes` (`table_name`);
CREATE INDEX `on_message_id` ON `spam_checks` (`message_id`);
CREATE INDEX `on_code` ON `spam_checks` (`code`);
CREATE INDEX `on_address` ON `suppressions` (`address`);
CREATE INDEX `on_keep_until` ON `suppressions` (`keep_until`);
CREATE INDEX `on_uuid` ON `webhook_requests` (`uuid`);
CREATE INDEX `on_event` ON `webhook_requests` (`event`);
CREATE INDEX `on_timestamp` ON `webhook_requests` (`timestamp`);
CREATE INDEX `on_webhook_id` ON `webhook_requests` (`webhook_id`);
