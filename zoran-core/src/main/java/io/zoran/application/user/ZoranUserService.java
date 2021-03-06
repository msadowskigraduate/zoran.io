package io.zoran.application.user;

import io.zoran.domain.user.User;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.user.OAuth2User;

/**
 * @author Michal Sadowski (michal.sadowski@roche.com) on 17.11.2018
 */
public interface ZoranUserService extends OAuth2UserService<OAuth2UserRequest, OAuth2User> {
    User getCurrentUser();
    String authenticateAndGetUserId();
    User authenticateUser(User user);
    User authenticateUser(String userId);
    User getUserByNameOrId(String nameOrId);
    void revokeAccessFor(User user);
    void revokeAccessFor(String userId);
    User activateUser();
    String getAccessToken();
}
