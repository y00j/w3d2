
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);



CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body  TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  like_status BOOLEAN,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES users(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Nima', 'Partovi'),
  ('Yujie', 'Zhu'),
  ('woody', 'wood');


INSERT INTO
  questions(title, body, author_id)
VALUES
  ('what is the color fo the sky', 'Someone please explain this to me I don''t get it',(SELECT id FROM users WHERE users.fname='Nima' AND users.lname='Partovi')),
  ('Where is my lawyer', 'I am poor and need one for free', (SELECT id FROM users WHERE users.fname='Yujie' AND users.lname='Zhu'));

  INSERT INTO
    question_follows(question_id, user_id)
  VALUES
    ((SELECT id FROM questions WHERE id=1 ), (SELECT id from users WHERE fname='Nima' AND lname='Partovi')),
    ((SELECT id FROM questions WHERE id=2 ), (SELECT id from users WHERE fname='Yujie' AND lname='Zhu'));

  INSERT INTO
    replies(question_id, parent_id, user_id, body)
  VALUES
    ((SELECT id from questions WHERE id= 1), NULL, (SELECT id FROM users WHERE id=2), 'Hey Nima, the sky is blue dummy'),
    ((SELECT id from questions WHERE id = 1), 1 , (SELECT id from users WHERE id=3), 'Yeah Nima, just look up... wow just join Hack Reactor');
    -- (2, NULL, 1, 'You need to get a job first'); (SELECT id from question_follows WHERE question_id=2)

  INSERT INTO
    question_likes(like_status, user_id, question_id)
  VALUES
    ('TRUE', 1, 1),
    ('TRUE', 2, 2),
    ('FALSE', 3, 1),
    ('FALSE', 3, 2);
