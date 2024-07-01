DROP TABLE IF EXISTS account CASCADE;

CREATE TABLE account (
                         id BIGINT NOT NULL,
                         receive_emails BOOLEAN NOT NULL DEFAULT FALSE,
                         receive_push BOOLEAN NOT NULL DEFAULT FALSE,
                         allow_data_share BOOLEAN NOT NULL DEFAULT FALSE,
                         profile_visibility BOOLEAN NOT NULL DEFAULT FALSE,
                         transaction_history_visible BOOLEAN NOT NULL DEFAULT FALSE,
                         want_to_receive_marketing BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE account ADD CONSTRAINT pk_account PRIMARY KEY (id);

INSERT INTO account (id, receive_emails, receive_push, allow_data_share, profile_visibility, transaction_history_visible, want_to_receive_marketing) VALUES (1, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE);
