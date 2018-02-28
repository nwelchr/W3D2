-- USERS

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

-- QUESTIONS

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

-- QUESTION_FOLLOWS

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- REPLIES

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

-- QUESTION_LIKES

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- USERS

INSERT INTO users (fname, lname) VALUES ('Sally', 'McDonalds');
INSERT INTO users (fname, lname) VALUES ('Toderson', 'Smeargle');
INSERT INTO users (fname, lname) VALUES ('Rory', 'Michaelson');
INSERT INTO users (fname, lname) VALUES ('Michtel', 'Michtels');

-- QUESTIONS

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Does this work?', "Testing out whether this works.", (SELECT id FROM users WHERE fname = 'Sally' AND lname = 'McDonalds'));

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Question 2', "Still testing. 2", (SELECT id FROM users WHERE fname = 'Toderson'));

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Question 3', "Getting points.", (SELECT id FROM users WHERE fname = 'Sally' AND lname = 'McDonalds'));

-- QUESTION_FOLLOWS

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Rory'), (SELECT id FROM questions WHERE title = 'Does this work?'));
INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Toderson'), (SELECT id FROM questions WHERE title = 'Does this work?'));
INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Sally'), (SELECT id FROM questions WHERE title = 'Does this work?'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Michtel'), (SELECT id FROM questions WHERE title = 'Question 2'));

-- REPLIES

INSERT INTO
  replies (body, user_id, question_id, parent_id)
VALUES
  ('This is a reply.', (SELECT id FROM users WHERE fname = 'Toderson'), (SELECT id FROM questions WHERE title = 'Does this work?'), NULL);

INSERT INTO
  replies (body, user_id, question_id, parent_id)
VALUES
  ('This is a reply to the reply.', (SELECT id FROM users WHERE fname = 'Rory'), (SELECT id FROM questions WHERE title = 'Does this work?'), (SELECT id FROM replies WHERE body = 'This is a reply.'));


-- QUESTION_LIKES

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Sally'), (SELECT id FROM questions WHERE title = 'Does this work?'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Rory'), (SELECT id FROM questions WHERE title = 'Question 2'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Michtel'), (SELECT id FROM questions WHERE title = 'Question 2'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Rory'), (SELECT id FROM questions WHERE title = 'Question 3'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Michtel'), (SELECT id FROM questions WHERE title = 'Question 3'));
