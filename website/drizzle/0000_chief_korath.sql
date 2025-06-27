DO $$ BEGIN
 CREATE TYPE "public"."notification_type" AS ENUM('HOPIUM', 'SYSTEM', 'TRANSFER', 'RUG_PULL');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."prediction_market_status" AS ENUM('ACTIVE', 'RESOLVED', 'CANCELLED');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."transaction_type" AS ENUM('BUY', 'SELL', 'TRANSFER_IN', 'TRANSFER_OUT');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "account" (
	"id" serial PRIMARY KEY NOT NULL,
	"account_id" text NOT NULL,
	"provider_id" text NOT NULL,
	"user_id" integer NOT NULL,
	"access_token" text,
	"refresh_token" text,
	"id_token" text,
	"access_token_expires_at" timestamp with time zone,
	"refresh_token_expires_at" timestamp with time zone,
	"scope" text,
	"password" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "account_deletion_request" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"requested_at" timestamp with time zone DEFAULT now() NOT NULL,
	"scheduled_deletion_at" timestamp with time zone NOT NULL,
	"reason" text,
	"is_processed" boolean DEFAULT false NOT NULL,
	CONSTRAINT "account_deletion_request_user_id_unique" UNIQUE("user_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "apikey" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text,
	"start" text,
	"prefix" text,
	"key" text NOT NULL,
	"user_id" integer NOT NULL,
	"refill_interval" integer,
	"refill_amount" integer,
	"last_refill_at" timestamp,
	"enabled" boolean,
	"rate_limit_enabled" boolean,
	"rate_limit_time_window" integer,
	"rate_limit_max" integer,
	"request_count" integer,
	"remaining" integer,
	"last_request" timestamp,
	"expires_at" timestamp,
	"created_at" timestamp NOT NULL,
	"updated_at" timestamp NOT NULL,
	"permissions" text,
	"metadata" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "coin" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"symbol" varchar(10) NOT NULL,
	"icon" text,
	"creator_id" integer,
	"initial_supply" numeric(30, 8) NOT NULL,
	"circulating_supply" numeric(30, 8) NOT NULL,
	"current_price" numeric(20, 8) NOT NULL,
	"market_cap" numeric(30, 2) NOT NULL,
	"volume_24h" numeric(30, 2) DEFAULT '0.00',
	"change_24h" numeric(30, 4) DEFAULT '0.0000',
	"pool_coin_amount" numeric(30, 8) DEFAULT '0.00000000' NOT NULL,
	"pool_base_currency_amount" numeric(30, 8) DEFAULT '0.00000000' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"is_listed" boolean DEFAULT true NOT NULL,
	CONSTRAINT "coin_symbol_unique" UNIQUE("symbol")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "comment" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer,
	"coin_id" integer NOT NULL,
	"content" varchar(500) NOT NULL,
	"likes_count" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"is_deleted" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "comment_like" (
	"user_id" integer NOT NULL,
	"comment_id" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "comment_like_user_id_comment_id_pk" PRIMARY KEY("user_id","comment_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "notification" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"type" "notification_type" NOT NULL,
	"title" varchar(200) NOT NULL,
	"message" text NOT NULL,
	"is_read" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "prediction_bet" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer,
	"question_id" integer NOT NULL,
	"side" boolean NOT NULL,
	"amount" numeric(20, 8) NOT NULL,
	"actual_winnings" numeric(20, 8),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"settled_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "prediction_question" (
	"id" serial PRIMARY KEY NOT NULL,
	"creator_id" integer,
	"question" varchar(200) NOT NULL,
	"status" "prediction_market_status" DEFAULT 'ACTIVE' NOT NULL,
	"resolution_date" timestamp with time zone NOT NULL,
	"ai_resolution" boolean,
	"total_yes_amount" numeric(20, 8) DEFAULT '0.00000000' NOT NULL,
	"total_no_amount" numeric(20, 8) DEFAULT '0.00000000' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"resolved_at" timestamp with time zone,
	"requires_web_search" boolean DEFAULT false NOT NULL,
	"validation_reason" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "price_history" (
	"id" serial PRIMARY KEY NOT NULL,
	"coin_id" integer NOT NULL,
	"price" numeric(20, 8) NOT NULL,
	"timestamp" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "promo_code" (
	"id" serial PRIMARY KEY NOT NULL,
	"code" varchar(50) NOT NULL,
	"description" text,
	"reward_amount" numeric(20, 8) NOT NULL,
	"max_uses" integer,
	"is_active" boolean DEFAULT true NOT NULL,
	"expires_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_by" integer,
	CONSTRAINT "promo_code_code_unique" UNIQUE("code")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "promo_code_redemption" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer,
	"promo_code_id" integer NOT NULL,
	"reward_amount" numeric(20, 8) NOT NULL,
	"redeemed_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "promo_code_redemption_user_id_promo_code_id_unique" UNIQUE("user_id","promo_code_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "session" (
	"id" serial PRIMARY KEY NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"token" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"user_id" integer NOT NULL,
	CONSTRAINT "session_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "transaction" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer,
	"coin_id" integer NOT NULL,
	"type" "transaction_type" NOT NULL,
	"quantity" numeric(30, 8) NOT NULL,
	"price_per_coin" numeric(20, 8) NOT NULL,
	"total_base_currency_amount" numeric(30, 8) NOT NULL,
	"timestamp" timestamp with time zone DEFAULT now() NOT NULL,
	"recipient_user_id" integer,
	"sender_user_id" integer
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false NOT NULL,
	"image" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"is_admin" boolean DEFAULT false,
	"is_banned" boolean DEFAULT false,
	"ban_reason" text,
	"base_currency_balance" numeric(20, 8) DEFAULT '100.00000000' NOT NULL,
	"bio" varchar(160) DEFAULT 'Hello am 48 year old man from somalia. Sorry for my bed england. I selled my wife for internet connection for play “conter stirk”',
	"username" varchar(30) NOT NULL,
	"volume_master" numeric(3, 2) DEFAULT '0.70' NOT NULL,
	"volume_muted" boolean DEFAULT false NOT NULL,
	"last_reward_claim" timestamp with time zone,
	"total_rewards_claimed" numeric(20, 8) DEFAULT '0.00000000' NOT NULL,
	"login_streak" integer DEFAULT 0 NOT NULL,
	"prestige_level" integer DEFAULT 0,
	CONSTRAINT "user_email_unique" UNIQUE("email"),
	CONSTRAINT "user_username_unique" UNIQUE("username")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user_portfolio" (
	"user_id" integer NOT NULL,
	"coin_id" integer NOT NULL,
	"quantity" numeric(30, 8) NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_portfolio_user_id_coin_id_pk" PRIMARY KEY("user_id","coin_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "verification" (
	"id" serial PRIMARY KEY NOT NULL,
	"identifier" text NOT NULL,
	"value" text NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "account" ADD CONSTRAINT "account_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "account_deletion_request" ADD CONSTRAINT "account_deletion_request_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "apikey" ADD CONSTRAINT "apikey_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "coin" ADD CONSTRAINT "coin_creator_id_user_id_fk" FOREIGN KEY ("creator_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "comment" ADD CONSTRAINT "comment_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "comment" ADD CONSTRAINT "comment_coin_id_coin_id_fk" FOREIGN KEY ("coin_id") REFERENCES "public"."coin"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "comment_like" ADD CONSTRAINT "comment_like_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "comment_like" ADD CONSTRAINT "comment_like_comment_id_comment_id_fk" FOREIGN KEY ("comment_id") REFERENCES "public"."comment"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "notification" ADD CONSTRAINT "notification_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "prediction_bet" ADD CONSTRAINT "prediction_bet_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "prediction_bet" ADD CONSTRAINT "prediction_bet_question_id_prediction_question_id_fk" FOREIGN KEY ("question_id") REFERENCES "public"."prediction_question"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "prediction_question" ADD CONSTRAINT "prediction_question_creator_id_user_id_fk" FOREIGN KEY ("creator_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "price_history" ADD CONSTRAINT "price_history_coin_id_coin_id_fk" FOREIGN KEY ("coin_id") REFERENCES "public"."coin"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "promo_code" ADD CONSTRAINT "promo_code_created_by_user_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "promo_code_redemption" ADD CONSTRAINT "promo_code_redemption_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "promo_code_redemption" ADD CONSTRAINT "promo_code_redemption_promo_code_id_promo_code_id_fk" FOREIGN KEY ("promo_code_id") REFERENCES "public"."promo_code"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "session" ADD CONSTRAINT "session_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "transaction" ADD CONSTRAINT "transaction_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "transaction" ADD CONSTRAINT "transaction_coin_id_coin_id_fk" FOREIGN KEY ("coin_id") REFERENCES "public"."coin"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "transaction" ADD CONSTRAINT "transaction_recipient_user_id_user_id_fk" FOREIGN KEY ("recipient_user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "transaction" ADD CONSTRAINT "transaction_sender_user_id_user_id_fk" FOREIGN KEY ("sender_user_id") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_portfolio" ADD CONSTRAINT "user_portfolio_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_portfolio" ADD CONSTRAINT "user_portfolio_coin_id_coin_id_fk" FOREIGN KEY ("coin_id") REFERENCES "public"."coin"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "account_deletion_request_user_id_idx" ON "account_deletion_request" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "account_deletion_request_scheduled_deletion_idx" ON "account_deletion_request" USING btree ("scheduled_deletion_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "account_deletion_request_open_idx" ON "account_deletion_request" USING btree ("user_id") WHERE is_processed = false;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_apikey_user" ON "apikey" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_symbol_idx" ON "coin" USING btree ("symbol");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_creator_id_idx" ON "coin" USING btree ("creator_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_is_listed_idx" ON "coin" USING btree ("is_listed");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_market_cap_idx" ON "coin" USING btree ("market_cap");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_current_price_idx" ON "coin" USING btree ("current_price");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_change24h_idx" ON "coin" USING btree ("change_24h");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_volume24h_idx" ON "coin" USING btree ("volume_24h");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "coin_created_at_idx" ON "coin" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "comment_user_id_idx" ON "comment" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "comment_coin_id_idx" ON "comment" USING btree ("coin_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "notification_user_id_idx" ON "notification" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "notification_type_idx" ON "notification" USING btree ("type");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "notification_is_read_idx" ON "notification" USING btree ("is_read");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "notification_created_at_idx" ON "notification" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_bet_user_id_idx" ON "prediction_bet" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_bet_question_id_idx" ON "prediction_bet" USING btree ("question_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_bet_user_question_idx" ON "prediction_bet" USING btree ("user_id","question_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_bet_created_at_idx" ON "prediction_bet" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_question_creator_id_idx" ON "prediction_question" USING btree ("creator_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_question_status_idx" ON "prediction_question" USING btree ("status");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_question_resolution_date_idx" ON "prediction_question" USING btree ("resolution_date");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "prediction_question_status_resolution_idx" ON "prediction_question" USING btree ("status","resolution_date");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transaction_user_id_idx" ON "transaction" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transaction_coin_id_idx" ON "transaction" USING btree ("coin_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transaction_type_idx" ON "transaction" USING btree ("type");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transaction_timestamp_idx" ON "transaction" USING btree ("timestamp");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transaction_user_coin_idx" ON "transaction" USING btree ("user_id","coin_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "transaction_coin_type_idx" ON "transaction" USING btree ("coin_id","type");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "user_username_idx" ON "user" USING btree ("username");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "user_is_banned_idx" ON "user" USING btree ("is_banned");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "user_is_admin_idx" ON "user" USING btree ("is_admin");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "user_created_at_idx" ON "user" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "user_updated_at_idx" ON "user" USING btree ("updated_at");