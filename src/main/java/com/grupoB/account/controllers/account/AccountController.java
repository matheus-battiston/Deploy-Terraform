package com.grupoB.account.controllers.account;

import com.grupoB.account.domain.services.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/account")
public class AccountController {
    private AccountService accountService;

    @Autowired
    public AccountController(AccountService accountService){
        this.accountService = accountService;
    }

    @GetMapping("/testdeploy")
    public String testDeploy() {
        return "Deploy funcionou";
    }
    @GetMapping("/preferences")
    public ResponseEntity<?> getAccount(@RequestParam("id") Integer id){
        AccountDTO accountDTO = accountService.getAccount(id);

        if(accountDTO == null){
            String errorMessage = "The provided account was not found.";
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", errorMessage);
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(errorResponse);
        }
        return  ResponseEntity
                .status(HttpStatus.OK)
                .body(accountDTO);
    }
    @PostMapping("/preferences")
    public ResponseEntity<?> setAccount(@RequestParam("id") Integer id, @RequestBody AccountDTO accountDTO){
        AccountDTO newAccountDTO = accountService.setAccount(id,accountDTO);
        if(newAccountDTO == null){
            String errorMessage = "The provided account was already set.";
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", errorMessage);
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(errorResponse);
        }
        return  ResponseEntity
                .status(HttpStatus.OK)
                .body(accountDTO);
    }
    @PutMapping("/preferences")
    public ResponseEntity<?> putAccount(@RequestParam("id") Integer id, @RequestBody AccountDTO accountDTO){
        AccountDTO updatedAccountDTO = accountService.updatePreferences(id,accountDTO);
        if(updatedAccountDTO == null){
            String errorMessage = "The provided account could not be found in our database.";
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", errorMessage);
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(errorResponse);
        }
        return  ResponseEntity
                .status(HttpStatus.OK)
                .body(accountDTO);
    }
    @PutMapping("/password")
    public ResponseEntity<?> putPassword(@RequestParam("id") Integer id, @RequestBody PasswordDTO password){
        Map<String, String> response = new HashMap<>();
        response.put("response", "The password was successfully updated.");
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(response);
    }
}
