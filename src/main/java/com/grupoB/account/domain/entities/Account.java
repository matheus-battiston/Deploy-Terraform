package com.grupoB.account.domain.entities;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.*;


@Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Getter
@Setter
@EqualsAndHashCode(of = "id") @ToString(of = "id")
public class Account {

        @Id
        private Long id;
        private Boolean receiveEmails;
        private Boolean receivePush;
        private Boolean allowDataShare;
        private Boolean profileVisibility;
        private Boolean transactionHistoryVisible;
        private Boolean  wantToReceiveMarketing;

    public Account(Boolean receiveEmails, Boolean receivePush, Boolean allowDataShare, Boolean profileVisibility,
                   Boolean transactionHistoryVisible, Boolean wantToReceiveMarketing, Integer id) {
        this.id = Long.valueOf(id);
        this.receiveEmails = receiveEmails;
        this.receivePush = receivePush;
        this.allowDataShare = allowDataShare;
        this.profileVisibility = profileVisibility;
        this.transactionHistoryVisible = transactionHistoryVisible;
        this.wantToReceiveMarketing = wantToReceiveMarketing;
    }

    public void setReceiveEmails(Boolean receiveEmails) {
        this.receiveEmails = receiveEmails;
    }

    public void setReceivePush(Boolean receivePush) {
        this.receivePush = receivePush;
    }

    public void setAllowDataShare(Boolean allowDataShare) {
        this.allowDataShare = allowDataShare;
    }

    public void setProfileVisibility(Boolean profileVisibility) {
        this.profileVisibility = profileVisibility;
    }

    public void setTransactionHistoryVisible(Boolean transactionHistoryVisible) {
        this.transactionHistoryVisible = transactionHistoryVisible;
    }

    public void setWantToReceiveMarketing(Boolean wantToReceiveMarketing) {
        this.wantToReceiveMarketing = wantToReceiveMarketing;
    }

    public void setId(Integer id) {
        this.id = Long.valueOf(id);
    }
}
