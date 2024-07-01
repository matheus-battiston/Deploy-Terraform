package com.grupoB.account.domain.services;

import com.grupoB.account.controllers.account.AccountDTO;
import com.grupoB.account.domain.entities.Account;
import com.grupoB.account.domain.repository.IRepoAccount;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.UNPROCESSABLE_ENTITY;

@Service
public class AccountService {
    @Autowired
    private IRepoAccount repoAccount;
    @Autowired
    public AccountService(IRepoAccount repoAccount){
        this.repoAccount = repoAccount;
    }
    public AccountDTO getAccount(Integer id){
        Account account = repoAccount.findById(id).orElseThrow(() -> new ResponseStatusException(UNPROCESSABLE_ENTITY, "Usuario nao encontrado"));

        return new AccountDTO(account.getReceiveEmails(),account.getReceivePush(),
                account.getAllowDataShare(), account.getProfileVisibility(),
                account.getTransactionHistoryVisible(),account.getWantToReceiveMarketing());

    }

    @Transactional
    public AccountDTO setAccount(Integer id, AccountDTO accountDTO){
        Boolean hasAlreadyAccount = repoAccount.existsById(id);

        if(hasAlreadyAccount){
            return null;
        }

        Account newAccount = new Account(accountDTO.receiveEmails(),accountDTO.receivePush(),
                accountDTO.allowDataShare(),accountDTO.profileVisibility(),
                accountDTO.transactionHistoryVisible(),
                accountDTO.wantToReceiveMarketing(), id);


        repoAccount.save(newAccount);

        return new AccountDTO(newAccount.getReceiveEmails(),newAccount.getReceivePush(),
                              newAccount.getAllowDataShare(), newAccount.getProfileVisibility(),
                              newAccount.getTransactionHistoryVisible(),newAccount.getWantToReceiveMarketing());
    }


    @Transactional
    public AccountDTO updatePreferences(Integer id, AccountDTO accountDTO){
        Account account = repoAccount.findById(id).orElseThrow(() -> new ResponseStatusException(UNPROCESSABLE_ENTITY, "Usuario nao encontrado"));
        account.setAllowDataShare(accountDTO.allowDataShare());
        account.setProfileVisibility(accountDTO.profileVisibility());
        account.setReceiveEmails(accountDTO.receiveEmails());
        account.setReceivePush(accountDTO.receivePush());
        account.setTransactionHistoryVisible(accountDTO.transactionHistoryVisible());
        account.setWantToReceiveMarketing(accountDTO.wantToReceiveMarketing());

        repoAccount.save(account);

        return new AccountDTO(account.getReceiveEmails(),account.getReceivePush(),
                account.getAllowDataShare(), account.getProfileVisibility(),
                account.getTransactionHistoryVisible(),account.getWantToReceiveMarketing());
    }

}
