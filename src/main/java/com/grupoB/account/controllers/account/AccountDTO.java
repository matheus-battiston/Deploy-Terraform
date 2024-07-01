package com.grupoB.account.controllers.account;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AccountDTO(@JsonProperty("receive_emails") Boolean receiveEmails, 
                         @JsonProperty("receive_push") Boolean receivePush, 
                         @JsonProperty("allow_data_share") Boolean allowDataShare,
                         @JsonProperty("profile_visibility") Boolean profileVisibility,
                         @JsonProperty("transaction_history_visible") Boolean transactionHistoryVisible, 
                         @JsonProperty("want_to_receive_marketing") Boolean wantToReceiveMarketing ) {
}
