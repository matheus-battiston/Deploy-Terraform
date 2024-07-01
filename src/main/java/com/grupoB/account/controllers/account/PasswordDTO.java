package com.grupoB.account.controllers.account;

import com.fasterxml.jackson.annotation.JsonProperty;

public record PasswordDTO(@JsonProperty("old_password") String oldPassword, 
                          @JsonProperty("new_password") String newPassword, 
                          @JsonProperty("new_password_confirmation") String newPasswordConfirmation) {
}
