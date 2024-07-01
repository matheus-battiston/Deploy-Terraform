package com.grupoB.account.domain.repository;


import com.grupoB.account.domain.entities.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface IRepoAccount extends JpaRepository<Account, Long> {
    Optional<Account> findById(Integer id);
    Boolean existsById(Integer id);
}
