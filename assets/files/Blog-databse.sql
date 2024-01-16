CREATE TYPE "user_role" AS ENUM (
  'USER',
  'ADMIN',
  'OWNER'
);

CREATE TYPE "like_type" AS ENUM (
  'UP',
  'DOWN'
);

CREATE TABLE "user" (
  "id" serial PRIMARY KEY,
  "username" varchar(128) UNIQUE NOT NULL,
  "email" varchar(128) UNIQUE NOT NULL,
  "password" varchar(255) NOT NULL DEFAULT 'EMPTY',
  "profile_picture" varchar,
  "verified" boolean DEFAULT false,
  "verification_token" varchar,
  "deleted" bool NOT NULL DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz
);

CREATE TABLE "user_roles" (
  "user_id" int,
  "role" user_role DEFAULT 'USER',
  "created_at" timestamptz DEFAULT (now()),
  PRIMARY KEY ("user_id", "role")
);

CREATE TABLE "password_reset_token" (
  "id" serial PRIMARY KEY,
  "token" UUID NOT NULL,
  "expiration" timestamptz NOT NULL DEFAULT (now() + interval '15' ),
  "used" boolean NOT NULL DEFAULT false,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "user_password_reset_tokens" (
  "user_id" int,
  "reset_token" int,
  "created_at" timestamptz DEFAULT (now()),
  PRIMARY KEY ("user_id")
);

CREATE TABLE "refresh_token" (
  "id" serial PRIMARY KEY,
  "token" UUID NOT NULL,
  "expires" timestamptz NOT NULL DEFAULT (now() + interval '1 days' ),
  "active" boolean NOT NULL DEFAULT true,
  "revoked" timestamptz,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "user_refresh_tokens" (
  "user_id" int,
  "refresh_token_id" int,
  "created_at" timestamptz DEFAULT (now()),
  PRIMARY KEY ("user_id")
);

CREATE TABLE "category" (
  "id" serial PRIMARY KEY,
  "name" varchar(64) UNIQUE NOT NULL,
  "slug" varchar(64) UNIQUE NOT NULL,
  "details" text,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz
);

CREATE TABLE "post" (
  "id" serial PRIMARY KEY,
  "title" varchar(64) UNIQUE NOT NULL,
  "slug" varchar(64) UNIQUE NOT NULL,
  "body" text NOT NULL,
  "author_id" integer,
  "published" boolean NOT NULL DEFAULT true,
  "publish_time" timestamptz,
  "category" int,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz
);

CREATE TABLE "tag" (
  "id" serial PRIMARY KEY,
  "name" varchar(64) UNIQUE NOT NULL,
  "slug" varchar(64) UNIQUE NOT NULL,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz
);

CREATE TABLE "post_tag" (
  "post_id" integer NOT NULL,
  "tag_id" integer NOT NULL,
  PRIMARY KEY ("tag_id", "post_id")
);

CREATE TABLE "comment" (
  "id" serial PRIMARY KEY,
  "body" text NOT NULL,
  "active" bool NOT NULL DEFAULT true,
  "post_id" integer NOT NULL,
  "author_id" integer NOT NULL,
  "parent_id" integer,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz
);

CREATE TABLE "post_likes" (
  "user_id" integer NOT NULL,
  "post_id" integer NOT NULL,
  "type" like_type,
  PRIMARY KEY ("user_id", "post_id")
);

CREATE TABLE "comment_likes" (
  "user_id" integer NOT NULL,
  "comment_id" integer NOT NULL,
  "type" like_type,
  PRIMARY KEY ("user_id", "comment_id")
);

CREATE INDEX ON "user" ("id");

CREATE INDEX ON "user" ("username");

CREATE INDEX ON "user" ("email");

CREATE INDEX ON "user" ("verification_token");

CREATE INDEX ON "user" ("deleted");

CREATE INDEX ON "password_reset_token" ("used");

CREATE INDEX ON "password_reset_token" ("token");

CREATE INDEX ON "refresh_token" ("token");

CREATE INDEX ON "category" ("id");

CREATE INDEX ON "category" ("name");

CREATE INDEX ON "category" ("slug");

CREATE INDEX ON "post" ("id");

CREATE INDEX ON "post" ("title");

CREATE INDEX ON "post" ("author_id");

CREATE INDEX ON "post" ("slug");

CREATE INDEX ON "post" ("published");

CREATE INDEX ON "tag" ("id");

CREATE INDEX ON "tag" ("name");

CREATE INDEX ON "tag" ("slug");

CREATE INDEX ON "comment" ("id");

CREATE INDEX ON "comment" ("author_id");

CREATE INDEX ON "comment" ("post_id");

CREATE INDEX ON "comment" ("parent_id");

CREATE INDEX ON "post_likes" ("user_id");

CREATE INDEX ON "post_likes" ("post_id");

CREATE INDEX ON "comment_likes" ("user_id");

CREATE INDEX ON "comment_likes" ("comment_id");

COMMENT ON TABLE "user" IS 'profile pictures: will be a string for simplicity
but could be a many to one relation like the other tables.
password : we expect it to come already hashed but can be simulated by SHA512().';

COMMENT ON COLUMN "user"."profile_picture" IS 'a string for now';

COMMENT ON COLUMN "user"."deleted" IS 'for soft deletion';

COMMENT ON TABLE "user_roles" IS 'a user can have many roles and it"s represented by this table';

COMMENT ON TABLE "password_reset_token" IS 'this table is for the password reset feature';

COMMENT ON COLUMN "password_reset_token"."expiration" IS '15 min from now';

COMMENT ON TABLE "user_password_reset_tokens" IS 'a user has ONLY one active reset token but this way we can keep track
of how many times they have reset their password.
can add in more tracking props';

COMMENT ON TABLE "refresh_token" IS 'see more about refresh tokens [here](https://auth0.com/blog/refresh-tokens-what-are-they-and-when-to-use-them/) ';

COMMENT ON COLUMN "refresh_token"."expires" IS '1 day from now';

COMMENT ON COLUMN "refresh_token"."revoked" IS 'when it dies, change later';

COMMENT ON TABLE "user_refresh_tokens" IS 'a user has many tokens but a token has only one user
this table exists cause a user may have more than one device';

COMMENT ON TABLE "category" IS 'a category is different from a tag in that it is more broad that a tag
and a post can only have on category.
to implement a sub category, this table would have to enter into a relation with itself
on "sub_category int [ref: > category.id]". not bothering with that now tho';

COMMENT ON TABLE "post" IS 'slug: the title trimmed, lowered cased, and spaces replaced by "-".
publish time: needs to be set and unset on the switching of the "Published" column.';

COMMENT ON COLUMN "post"."slug" IS 'look for a way to default trim the title field';

COMMENT ON COLUMN "post"."body" IS 'rich markdown hopfully';

COMMENT ON TABLE "tag" IS 'a tag is different that a category in that it is more focused
like a "game" or a "book" inside of warhammer 40k category';

COMMENT ON COLUMN "tag"."name" IS 'will be trimmed like a "slug" would';

COMMENT ON TABLE "post_tag" IS 'can have more properties, but this is the bare min';

COMMENT ON TABLE "comment" IS 'a table with a relation to itself ~lonely~ 
"body" : text cause cause i"d like it to be in markdown but 255 limit seems sweet
"active" : cause of soft delete approach and not to mess with the reply tree ;
  it will show as "deleted" in the front-end';

COMMENT ON COLUMN "comment"."active" IS 'for soft delation';

COMMENT ON TABLE "post_likes" IS 'we cannot create a generic table for all kinds of entities,
this is a good way i think';

COMMENT ON TABLE "comment_likes" IS 'we cannot create a generic table for all kinds of entities,
this is a good way i think';

ALTER TABLE "user_roles" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "user_password_reset_tokens" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "user_password_reset_tokens" ADD FOREIGN KEY ("reset_token") REFERENCES "password_reset_token" ("id");

ALTER TABLE "user_refresh_tokens" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "user_refresh_tokens" ADD FOREIGN KEY ("refresh_token_id") REFERENCES "refresh_token" ("id");

ALTER TABLE "post" ADD FOREIGN KEY ("author_id") REFERENCES "user" ("id");

ALTER TABLE "post" ADD FOREIGN KEY ("category") REFERENCES "category" ("id");

ALTER TABLE "post_tag" ADD FOREIGN KEY ("post_id") REFERENCES "post" ("id");

ALTER TABLE "post_tag" ADD FOREIGN KEY ("tag_id") REFERENCES "tag" ("id");

ALTER TABLE "comment" ADD FOREIGN KEY ("post_id") REFERENCES "post" ("id");

ALTER TABLE "comment" ADD FOREIGN KEY ("author_id") REFERENCES "user" ("id");

ALTER TABLE "comment" ADD FOREIGN KEY ("parent_id") REFERENCES "comment" ("id");

ALTER TABLE "post_likes" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "post_likes" ADD FOREIGN KEY ("post_id") REFERENCES "post" ("id");

ALTER TABLE "comment_likes" ADD FOREIGN KEY ("user_id") REFERENCES "user" ("id");

ALTER TABLE "comment_likes" ADD FOREIGN KEY ("comment_id") REFERENCES "comment" ("id");
