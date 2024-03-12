-- Current sql file was generated after introspecting the database
-- If you want to run this migration please uncomment this code before executing migrations

CREATE TABLE `clicks` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`message_id` int(11) DEFAULT NULL,
	`link_id` int(11) DEFAULT NULL,
	`ip_address` varchar(255) DEFAULT NULL,
	`country` varchar(255) DEFAULT NULL,
	`city` varchar(255) DEFAULT NULL,
	`user_agent` varchar(255) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `deliveries` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`message_id` int(11) DEFAULT NULL,
	`status` varchar(255) DEFAULT NULL,
	`code` int(11) DEFAULT NULL,
	`output` varchar(512) DEFAULT NULL,
	`details` varchar(512) DEFAULT NULL,
	`sent_with_ssl` tinyint DEFAULT 0,
	`log_id` varchar(100) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL,
	`time` decimal(8,2) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `links` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`message_id` int(11) DEFAULT NULL,
	`token` varchar(255) DEFAULT NULL,
	`hash` varchar(255) DEFAULT NULL,
	`url` text DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `live_stats` (
	`type` varchar(20) NOT NULL,
	`minute` int(11) NOT NULL,
	`count` int(11) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `loads` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`message_id` int(11) DEFAULT NULL,
	`ip_address` varchar(255) DEFAULT NULL,
	`country` varchar(255) DEFAULT NULL,
	`city` varchar(255) DEFAULT NULL,
	`user_agent` varchar(255) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `messages` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`token` varchar(255) DEFAULT NULL,
	`scope` varchar(10) DEFAULT NULL,
	`rcpt_to` varchar(255) DEFAULT NULL,
	`mail_from` varchar(255) DEFAULT NULL,
	`subject` varchar(255) DEFAULT NULL,
	`message_id` varchar(255) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL,
	`route_id` int(11) DEFAULT NULL,
	`domain_id` int(11) DEFAULT NULL,
	`credential_id` int(11) DEFAULT NULL,
	`status` varchar(255) DEFAULT NULL,
	`held` tinyint DEFAULT 0,
	`size` varchar(255) DEFAULT NULL,
	`last_delivery_attempt` decimal(18,6) DEFAULT NULL,
	`raw_table` varchar(255) DEFAULT NULL,
	`raw_body_id` int(11) DEFAULT NULL,
	`raw_headers_id` int(11) DEFAULT NULL,
	`inspected` tinyint DEFAULT 0,
	`spam` tinyint DEFAULT 0,
	`spam_score` decimal(8,2) DEFAULT '0.00',
	`threat` tinyint DEFAULT 0,
	`threat_details` varchar(255) DEFAULT NULL,
	`bounce` tinyint DEFAULT 0,
	`bounce_for_id` int(11) DEFAULT 0,
	`tag` varchar(255) DEFAULT NULL,
	`loaded` decimal(18,6) DEFAULT NULL,
	`clicked` decimal(18,6) DEFAULT NULL,
	`received_with_ssl` tinyint DEFAULT NULL,
	`hold_expiry` decimal(18,6) DEFAULT NULL,
	`tracked_links` int(11) DEFAULT 0,
	`tracked_images` int(11) DEFAULT 0,
	`parsed` tinyint DEFAULT 0,
	`endpoint_id` int(11) DEFAULT NULL,
	`endpoint_type` varchar(255) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `migrations` (
	`version` int(11) NOT NULL
);
--> statement-breakpoint
CREATE TABLE `raw_message_sizes` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`table_name` varchar(255) DEFAULT NULL,
	`size` bigint(20) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `spam_checks` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`message_id` int(11) DEFAULT NULL,
	`score` decimal(8,2) DEFAULT NULL,
	`code` varchar(255) DEFAULT NULL,
	`description` varchar(255) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `stats_daily` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`time` int(11) DEFAULT NULL,
	`incoming` bigint(20) DEFAULT NULL,
	`outgoing` bigint(20) DEFAULT NULL,
	`spam` bigint(20) DEFAULT NULL,
	`bounces` bigint(20) DEFAULT NULL,
	`held` bigint(20) DEFAULT NULL,
	CONSTRAINT `on_time` UNIQUE(`time`)
);
--> statement-breakpoint
CREATE TABLE `stats_hourly` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`time` int(11) DEFAULT NULL,
	`incoming` bigint(20) DEFAULT NULL,
	`outgoing` bigint(20) DEFAULT NULL,
	`spam` bigint(20) DEFAULT NULL,
	`bounces` bigint(20) DEFAULT NULL,
	`held` bigint(20) DEFAULT NULL,
	CONSTRAINT `on_time` UNIQUE(`time`)
);
--> statement-breakpoint
CREATE TABLE `stats_monthly` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`time` int(11) DEFAULT NULL,
	`incoming` bigint(20) DEFAULT NULL,
	`outgoing` bigint(20) DEFAULT NULL,
	`spam` bigint(20) DEFAULT NULL,
	`bounces` bigint(20) DEFAULT NULL,
	`held` bigint(20) DEFAULT NULL,
	CONSTRAINT `on_time` UNIQUE(`time`)
);
--> statement-breakpoint
CREATE TABLE `stats_yearly` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`time` int(11) DEFAULT NULL,
	`incoming` bigint(20) DEFAULT NULL,
	`outgoing` bigint(20) DEFAULT NULL,
	`spam` bigint(20) DEFAULT NULL,
	`bounces` bigint(20) DEFAULT NULL,
	`held` bigint(20) DEFAULT NULL,
	CONSTRAINT `on_time` UNIQUE(`time`)
);
--> statement-breakpoint
CREATE TABLE `suppressions` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`type` varchar(255) DEFAULT NULL,
	`address` varchar(255) DEFAULT NULL,
	`reason` varchar(255) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL,
	`keep_until` decimal(18,6) DEFAULT NULL
);
--> statement-breakpoint
CREATE TABLE `webhook_requests` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT NULL,
	`event` varchar(255) DEFAULT NULL,
	`attempt` int(11) DEFAULT NULL,
	`timestamp` decimal(18,6) DEFAULT NULL,
	`status_code` int(1) DEFAULT NULL,
	`body` text DEFAULT NULL,
	`payload` text DEFAULT NULL,
	`will_retry` tinyint DEFAULT NULL,
	`url` varchar(255) DEFAULT NULL,
	`webhook_id` int(11) DEFAULT NULL
);
--> statement-breakpoint
CREATE INDEX `on_message_id` ON `clicks` (`message_id`);--> statement-breakpoint
CREATE INDEX `on_link_id` ON `clicks` (`link_id`);--> statement-breakpoint
CREATE INDEX `on_message_id` ON `deliveries` (`message_id`);--> statement-breakpoint
CREATE INDEX `on_message_id` ON `links` (`message_id`);--> statement-breakpoint
CREATE INDEX `on_token` ON `links` (`token`);--> statement-breakpoint
CREATE INDEX `on_message_id` ON `loads` (`message_id`);--> statement-breakpoint
CREATE INDEX `on_message_id` ON `messages` (`message_id`);--> statement-breakpoint
CREATE INDEX `on_token` ON `messages` (`token`);--> statement-breakpoint
CREATE INDEX `on_bounce_for_id` ON `messages` (`bounce_for_id`);--> statement-breakpoint
CREATE INDEX `on_held` ON `messages` (`held`);--> statement-breakpoint
CREATE INDEX `on_scope_and_status` ON `messages` (`scope`,`spam`,`status`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_scope_and_tag` ON `messages` (`scope`,`spam`,`tag`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_scope_and_spam` ON `messages` (`scope`,`spam`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_scope_and_thr_status` ON `messages` (`scope`,`threat`,`status`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_scope_and_threat` ON `messages` (`scope`,`threat`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_rcpt_to` ON `messages` (`rcpt_to`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_mail_from` ON `messages` (`mail_from`,`timestamp`);--> statement-breakpoint
CREATE INDEX `on_raw_table` ON `messages` (`raw_table`);--> statement-breakpoint
CREATE INDEX `on_status` ON `messages` (`status`);--> statement-breakpoint
CREATE INDEX `on_table_name` ON `raw_message_sizes` (`table_name`);--> statement-breakpoint
CREATE INDEX `on_message_id` ON `spam_checks` (`message_id`);--> statement-breakpoint
CREATE INDEX `on_code` ON `spam_checks` (`code`);--> statement-breakpoint
CREATE INDEX `on_address` ON `suppressions` (`address`);--> statement-breakpoint
CREATE INDEX `on_keep_until` ON `suppressions` (`keep_until`);--> statement-breakpoint
CREATE INDEX `on_uuid` ON `webhook_requests` (`uuid`);--> statement-breakpoint
CREATE INDEX `on_event` ON `webhook_requests` (`event`);--> statement-breakpoint
CREATE INDEX `on_timestamp` ON `webhook_requests` (`timestamp`);--> statement-breakpoint
CREATE INDEX `on_webhook_id` ON `webhook_requests` (`webhook_id`);
