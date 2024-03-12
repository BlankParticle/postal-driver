-- Current sql file was generated after introspecting the database
-- If you want to run this migration please uncomment this code before executing migrations
/*
CREATE TABLE `additional_route_endpoints` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`route_id` int(11) DEFAULT 'NULL',
	`endpoint_type` varchar(255) DEFAULT 'NULL',
	`endpoint_id` int(11) DEFAULT 'NULL',
	`created_at` datetime NOT NULL,
	`updated_at` datetime NOT NULL
);
--> statement-breakpoint
CREATE TABLE `address_endpoints` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`address` varchar(255) DEFAULT 'NULL',
	`last_used_at` datetime DEFAULT 'NULL',
	`created_at` datetime NOT NULL,
	`updated_at` datetime NOT NULL
);
--> statement-breakpoint
CREATE TABLE `ar_internal_metadata` (
	`key` varchar(255) NOT NULL,
	`value` varchar(255) DEFAULT 'NULL',
	`created_at` datetime(6) NOT NULL,
	`updated_at` datetime(6) NOT NULL
);
--> statement-breakpoint
CREATE TABLE `authie_sessions` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`token` varchar(255) DEFAULT 'NULL',
	`browser_id` varchar(255) DEFAULT 'NULL',
	`user_id` int(11) DEFAULT 'NULL',
	`active` tinyint DEFAULT 1,
	`data` text DEFAULT 'NULL',
	`expires_at` datetime DEFAULT 'NULL',
	`login_at` datetime DEFAULT 'NULL',
	`login_ip` varchar(255) DEFAULT 'NULL',
	`last_activity_at` datetime DEFAULT 'NULL',
	`last_activity_ip` varchar(255) DEFAULT 'NULL',
	`last_activity_path` varchar(255) DEFAULT 'NULL',
	`user_agent` varchar(255) DEFAULT 'NULL',
	`created_at` datetime DEFAULT 'NULL',
	`updated_at` datetime DEFAULT 'NULL',
	`user_type` varchar(255) DEFAULT 'NULL',
	`parent_id` int(11) DEFAULT 'NULL',
	`two_factored_at` datetime DEFAULT 'NULL',
	`two_factored_ip` varchar(255) DEFAULT 'NULL',
	`requests` int(11) DEFAULT 0,
	`password_seen_at` datetime DEFAULT 'NULL',
	`token_hash` varchar(255) DEFAULT 'NULL',
	`host` varchar(255) DEFAULT 'NULL',
	`skip_two_factor` tinyint DEFAULT 0,
	`login_ip_country` varchar(255) DEFAULT 'NULL',
	`two_factored_ip_country` varchar(255) DEFAULT 'NULL',
	`last_activity_ip_country` varchar(255) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `credentials` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`key` varchar(255) DEFAULT 'NULL',
	`type` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`options` text DEFAULT 'NULL',
	`last_used_at` datetime(6) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`hold` tinyint DEFAULT 0,
	`uuid` varchar(255) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `domains` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`verification_token` varchar(255) DEFAULT 'NULL',
	`verification_method` varchar(255) DEFAULT 'NULL',
	`verified_at` datetime DEFAULT 'NULL',
	`dkim_private_key` text DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`dns_checked_at` datetime(6) DEFAULT 'NULL',
	`spf_status` varchar(255) DEFAULT 'NULL',
	`spf_error` varchar(255) DEFAULT 'NULL',
	`dkim_status` varchar(255) DEFAULT 'NULL',
	`dkim_error` varchar(255) DEFAULT 'NULL',
	`mx_status` varchar(255) DEFAULT 'NULL',
	`mx_error` varchar(255) DEFAULT 'NULL',
	`return_path_status` varchar(255) DEFAULT 'NULL',
	`return_path_error` varchar(255) DEFAULT 'NULL',
	`outgoing` tinyint DEFAULT 1,
	`incoming` tinyint DEFAULT 1,
	`owner_type` varchar(255) DEFAULT 'NULL',
	`owner_id` int(11) DEFAULT 'NULL',
	`dkim_identifier_string` varchar(255) DEFAULT 'NULL',
	`use_for_any` tinyint DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `http_endpoints` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`url` varchar(255) DEFAULT 'NULL',
	`encoding` varchar(255) DEFAULT 'NULL',
	`format` varchar(255) DEFAULT 'NULL',
	`strip_replies` tinyint DEFAULT 0,
	`error` text DEFAULT 'NULL',
	`disabled_until` datetime(6) DEFAULT 'NULL',
	`last_used_at` datetime(6) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`include_attachments` tinyint DEFAULT 1,
	`timeout` int(11) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `ip_addresses` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`ip_pool_id` int(11) DEFAULT 'NULL',
	`ipv4` varchar(255) DEFAULT 'NULL',
	`ipv6` varchar(255) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`hostname` varchar(255) DEFAULT 'NULL',
	`priority` int(11) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `ip_pools` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`name` varchar(255) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`default` tinyint DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE `ip_pool_rules` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT 'NULL',
	`owner_type` varchar(255) DEFAULT 'NULL',
	`owner_id` int(11) DEFAULT 'NULL',
	`ip_pool_id` int(11) DEFAULT 'NULL',
	`from_text` text DEFAULT 'NULL',
	`to_text` text DEFAULT 'NULL',
	`created_at` datetime NOT NULL,
	`updated_at` datetime NOT NULL
);
--> statement-breakpoint
CREATE TABLE `organizations` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`permalink` varchar(255) DEFAULT 'NULL',
	`time_zone` varchar(255) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`ip_pool_id` int(11) DEFAULT 'NULL',
	`owner_id` int(11) DEFAULT 'NULL',
	`deleted_at` datetime(6) DEFAULT 'NULL',
	`suspended_at` datetime(6) DEFAULT 'NULL',
	`suspension_reason` varchar(255) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `organization_ip_pools` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`organization_id` int(11) DEFAULT 'NULL',
	`ip_pool_id` int(11) DEFAULT 'NULL',
	`created_at` datetime NOT NULL,
	`updated_at` datetime NOT NULL
);
--> statement-breakpoint
CREATE TABLE `organization_users` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`organization_id` int(11) DEFAULT 'NULL',
	`user_id` int(11) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`admin` tinyint DEFAULT 0,
	`all_servers` tinyint DEFAULT 1,
	`user_type` varchar(255) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `queued_messages` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`message_id` int(11) DEFAULT 'NULL',
	`domain` varchar(255) DEFAULT 'NULL',
	`locked_by` varchar(255) DEFAULT 'NULL',
	`locked_at` datetime(6) DEFAULT 'NULL',
	`retry_after` datetime DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`ip_address_id` int(11) DEFAULT 'NULL',
	`attempts` int(11) DEFAULT 0,
	`route_id` int(11) DEFAULT 'NULL',
	`manual` tinyint DEFAULT 0,
	`batch_key` varchar(255) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `routes` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT 'NULL',
	`server_id` int(11) DEFAULT 'NULL',
	`domain_id` int(11) DEFAULT 'NULL',
	`endpoint_id` int(11) DEFAULT 'NULL',
	`endpoint_type` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`spam_mode` varchar(255) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`token` varchar(255) DEFAULT 'NULL',
	`mode` varchar(255) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `scheduled_tasks` (
	`id` bigint(20) AUTO_INCREMENT NOT NULL,
	`name` varchar(255) DEFAULT 'NULL',
	`next_run_after` datetime DEFAULT 'NULL',
	CONSTRAINT `index_scheduled_tasks_on_name` UNIQUE(`name`)
);
--> statement-breakpoint
CREATE TABLE `schema_migrations` (
	`version` varchar(255) NOT NULL
);
--> statement-breakpoint
CREATE TABLE `servers` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`organization_id` int(11) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`mode` varchar(255) DEFAULT 'NULL',
	`ip_pool_id` int(11) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`permalink` varchar(255) DEFAULT 'NULL',
	`send_limit` int(11) DEFAULT 'NULL',
	`deleted_at` datetime(6) DEFAULT 'NULL',
	`message_retention_days` int(11) DEFAULT 'NULL',
	`raw_message_retention_days` int(11) DEFAULT 'NULL',
	`raw_message_retention_size` int(11) DEFAULT 'NULL',
	`allow_sender` tinyint DEFAULT 0,
	`token` varchar(255) DEFAULT 'NULL',
	`send_limit_approaching_at` datetime(6) DEFAULT 'NULL',
	`send_limit_approaching_notified_at` datetime(6) DEFAULT 'NULL',
	`send_limit_exceeded_at` datetime(6) DEFAULT 'NULL',
	`send_limit_exceeded_notified_at` datetime(6) DEFAULT 'NULL',
	`spam_threshold` decimal(8,2) DEFAULT 'NULL',
	`spam_failure_threshold` decimal(8,2) DEFAULT 'NULL',
	`postmaster_address` varchar(255) DEFAULT 'NULL',
	`suspended_at` datetime(6) DEFAULT 'NULL',
	`outbound_spam_threshold` decimal(8,2) DEFAULT 'NULL',
	`domains_not_to_click_track` text DEFAULT 'NULL',
	`suspension_reason` varchar(255) DEFAULT 'NULL',
	`log_smtp_data` tinyint DEFAULT 0,
	`privacy_mode` tinyint DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE `smtp_endpoints` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`hostname` varchar(255) DEFAULT 'NULL',
	`ssl_mode` varchar(255) DEFAULT 'NULL',
	`port` int(11) DEFAULT 'NULL',
	`error` text DEFAULT 'NULL',
	`disabled_until` datetime(6) DEFAULT 'NULL',
	`last_used_at` datetime(6) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `statistics` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`total_messages` bigint(20) DEFAULT 0,
	`total_outgoing` bigint(20) DEFAULT 0,
	`total_incoming` bigint(20) DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE `track_certificates` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`domain` varchar(255) DEFAULT 'NULL',
	`certificate` text DEFAULT 'NULL',
	`intermediaries` text DEFAULT 'NULL',
	`key` text DEFAULT 'NULL',
	`expires_at` datetime DEFAULT 'NULL',
	`renew_after` datetime DEFAULT 'NULL',
	`verification_path` varchar(255) DEFAULT 'NULL',
	`verification_string` varchar(255) DEFAULT 'NULL',
	`created_at` datetime NOT NULL,
	`updated_at` datetime NOT NULL
);
--> statement-breakpoint
CREATE TABLE `track_domains` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT 'NULL',
	`server_id` int(11) DEFAULT 'NULL',
	`domain_id` int(11) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`dns_checked_at` datetime DEFAULT 'NULL',
	`dns_status` varchar(255) DEFAULT 'NULL',
	`dns_error` varchar(255) DEFAULT 'NULL',
	`created_at` datetime NOT NULL,
	`updated_at` datetime NOT NULL,
	`ssl_enabled` tinyint DEFAULT 1,
	`track_clicks` tinyint DEFAULT 1,
	`track_loads` tinyint DEFAULT 1,
	`excluded_click_domains` text DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `users` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT 'NULL',
	`first_name` varchar(255) DEFAULT 'NULL',
	`last_name` varchar(255) DEFAULT 'NULL',
	`email_address` varchar(255) DEFAULT 'NULL',
	`password_digest` varchar(255) DEFAULT 'NULL',
	`time_zone` varchar(255) DEFAULT 'NULL',
	`email_verification_token` varchar(255) DEFAULT 'NULL',
	`email_verified_at` datetime DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL',
	`password_reset_token` varchar(255) DEFAULT 'NULL',
	`password_reset_token_valid_until` datetime DEFAULT 'NULL',
	`admin` tinyint DEFAULT 0
);
--> statement-breakpoint
CREATE TABLE `user_invites` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`uuid` varchar(255) DEFAULT 'NULL',
	`email_address` varchar(255) DEFAULT 'NULL',
	`expires_at` datetime(6) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `webhooks` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`name` varchar(255) DEFAULT 'NULL',
	`url` varchar(255) DEFAULT 'NULL',
	`last_used_at` datetime DEFAULT 'NULL',
	`all_events` tinyint DEFAULT 0,
	`enabled` tinyint DEFAULT 1,
	`sign` tinyint DEFAULT 1,
	`created_at` datetime(6) DEFAULT 'NULL',
	`updated_at` datetime(6) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `webhook_events` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`webhook_id` int(11) DEFAULT 'NULL',
	`event` varchar(255) DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `webhook_requests` (
	`id` int(11) AUTO_INCREMENT NOT NULL,
	`server_id` int(11) DEFAULT 'NULL',
	`webhook_id` int(11) DEFAULT 'NULL',
	`url` varchar(255) DEFAULT 'NULL',
	`event` varchar(255) DEFAULT 'NULL',
	`uuid` varchar(255) DEFAULT 'NULL',
	`payload` text DEFAULT 'NULL',
	`attempts` int(11) DEFAULT 0,
	`retry_after` datetime(6) DEFAULT 'NULL',
	`error` text DEFAULT 'NULL',
	`created_at` datetime(6) DEFAULT 'NULL',
	`locked_by` varchar(255) DEFAULT 'NULL',
	`locked_at` datetime DEFAULT 'NULL'
);
--> statement-breakpoint
CREATE TABLE `worker_roles` (
	`id` bigint(20) AUTO_INCREMENT NOT NULL,
	`role` varchar(255) DEFAULT 'NULL',
	`worker` varchar(255) DEFAULT 'NULL',
	`acquired_at` datetime DEFAULT 'NULL',
	CONSTRAINT `index_worker_roles_on_role` UNIQUE(`role`)
);
--> statement-breakpoint
CREATE INDEX `index_authie_sessions_on_browser_id` ON `authie_sessions` (`browser_id`);--> statement-breakpoint
CREATE INDEX `index_authie_sessions_on_token` ON `authie_sessions` (`token`);--> statement-breakpoint
CREATE INDEX `index_authie_sessions_on_token_hash` ON `authie_sessions` (`token_hash`);--> statement-breakpoint
CREATE INDEX `index_authie_sessions_on_user_id` ON `authie_sessions` (`user_id`);--> statement-breakpoint
CREATE INDEX `index_domains_on_server_id` ON `domains` (`server_id`);--> statement-breakpoint
CREATE INDEX `index_domains_on_uuid` ON `domains` (`uuid`);--> statement-breakpoint
CREATE INDEX `index_ip_pools_on_uuid` ON `ip_pools` (`uuid`);--> statement-breakpoint
CREATE INDEX `index_organizations_on_permalink` ON `organizations` (`permalink`);--> statement-breakpoint
CREATE INDEX `index_organizations_on_uuid` ON `organizations` (`uuid`);--> statement-breakpoint
CREATE INDEX `index_queued_messages_on_domain` ON `queued_messages` (`domain`);--> statement-breakpoint
CREATE INDEX `index_queued_messages_on_message_id` ON `queued_messages` (`message_id`);--> statement-breakpoint
CREATE INDEX `index_queued_messages_on_server_id` ON `queued_messages` (`server_id`);--> statement-breakpoint
CREATE INDEX `index_routes_on_token` ON `routes` (`token`);--> statement-breakpoint
CREATE INDEX `index_servers_on_organization_id` ON `servers` (`organization_id`);--> statement-breakpoint
CREATE INDEX `index_servers_on_permalink` ON `servers` (`permalink`);--> statement-breakpoint
CREATE INDEX `index_servers_on_token` ON `servers` (`token`);--> statement-breakpoint
CREATE INDEX `index_servers_on_uuid` ON `servers` (`uuid`);--> statement-breakpoint
CREATE INDEX `index_track_certificates_on_domain` ON `track_certificates` (`domain`);--> statement-breakpoint
CREATE INDEX `index_users_on_email_address` ON `users` (`email_address`);--> statement-breakpoint
CREATE INDEX `index_users_on_uuid` ON `users` (`uuid`);--> statement-breakpoint
CREATE INDEX `index_user_invites_on_uuid` ON `user_invites` (`uuid`);--> statement-breakpoint
CREATE INDEX `index_webhooks_on_server_id` ON `webhooks` (`server_id`);--> statement-breakpoint
CREATE INDEX `index_webhook_events_on_webhook_id` ON `webhook_events` (`webhook_id`);--> statement-breakpoint
CREATE INDEX `index_webhook_requests_on_locked_by` ON `webhook_requests` (`locked_by`);
*/