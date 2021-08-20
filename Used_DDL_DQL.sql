# Used DDL and DQL

# PART 2. Create the DDL for new schema

CREATE TABLE users(
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(25) NOT NULL,
  "logged_in" DATE
);

CREATE UNIQUE INDEX ON users (LOWER("username"));

CREATE TABLE topics (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(30) UNIQUE NOT NULL,
  "description" VARCHAR(500)
);

CREATE TABLE comments (
  "id" SERIAL PRIMARY KEY,
  "text_content" TEXT NOT NULL,
  "user_id" INTEGER NOT NULL REFERENCES users ON DELETE SET NULL
);

CREATE INDEX ON comments ("id");

CREATE TABLE posts (
  "id" SERIAL PRIMARY KEY,
  "tile" VARCHAR(100) NOT NULL,
  "url" VARCHAR (1000) DEFAULT NULL,
  "text_content" TEXT DEFAULT NULL,
  "topic_id" INTEGER NOT NULL REFERENCES topics ON DELETE CASCADE,
  "user_id" INTEGER NOT NULL REFERENCES users ON DELETE SET NULL,
  "commnet_id" INTEGER REFERENCES comments ON DELETE CASCADE
);

CREATE INDEX ON posts ("url");

CREATE TABLE votes (
  "user_id" INTEGER REFERENCES users ON DELETE SET NULL,
  "post_id" INTEGER REFERENCES posts ON DELETE CASCADE,
  "votes" TEXT
);


# PART 3. Migrate the provided data

ALTER TABLE topics ALTER COLUMN "description" SET DEFAULT NULL;

INSERT INTO users ("username")
  SELECT DISTINCT username FROM bad_comments;

INSERT INTO comments ("text_content","user_id")
  SELECT DISTINCT b.text_content, u.id
  FROM bad_comments AS b
  JOIN users AS u ON b.username=u.username
  WHERE b.text_content IS NOT NULL AND b.username IS NOT NULL;

INSERT INTO topics ("name")
  SELECT DISTINCT topic FROM bad_posts;

INSERT INTO posts ("tile","url","text_content","topic_id","user_id")
  SELECT b.title, b.url, b.text_content, t.id, u.id
  FROM bad_posts AS b
  JOIN topics AS t ON b.topic=t.name
  JOIN users AS u ON u.username=b.username;

INSERT INTO votes ("user_id","post_id","votes")
  SELECT DISTINCT u.id, p.id, REGEXP_SPLIT_TO_TABLE(b.upvotes,',') AS votes
  FROM bad_posts AS b
  JOIN users AS u
  ON b.username=u.username
  JOIN posts AS p
  ON u.id=p.user_id;

INSERT INTO votes ("votes")
  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(b.downvotes,',') AS votes
  FROM bad_posts AS b
  JOIN users AS u
  ON b.username=u.username
  JOIN posts AS p
  ON u.id=p.user_id;
