package com.github.spartusch.adminserver;

import de.codecentric.boot.admin.server.config.AdminServerProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

@EnableWebSecurity
@Configuration(proxyBeanMethods = false)
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {

    private final AdminServerProperties adminServer;

    public SecurityConfiguration(AdminServerProperties adminServer) {
        this.adminServer = adminServer;
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        var successHandler = new SavedRequestAwareAuthenticationSuccessHandler();
        successHandler.setTargetUrlParameter("redirectTo");
        successHandler.setDefaultTargetUrl(adminServer.path("/"));

        http
                .authorizeRequests(authorizeRequests -> authorizeRequests
                        .antMatchers(adminServer.path("/assets/**")).permitAll()
                        .antMatchers(adminServer.path("/actuator/info")).permitAll()
                        .antMatchers(adminServer.path("/actuator/health")).permitAll()
                        .antMatchers(adminServer.path("/login")).permitAll()
                        .antMatchers(HttpMethod.POST, adminServer.path("/instances")).permitAll()
                        .antMatchers(HttpMethod.DELETE, adminServer.path("/instances/*")).permitAll()
                        .anyRequest().authenticated()
                )
                .formLogin(formLogin -> formLogin
                        .loginPage(adminServer.path("/login"))
                        .successHandler(successHandler).and()
                )
                .logout(logout -> logout.logoutUrl(adminServer.path("/logout")))
                .httpBasic(Customizer.withDefaults())
                .csrf(csrf -> csrf
                        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                        .ignoringRequestMatchers(
                                new AntPathRequestMatcher(adminServer.path("/instances"), HttpMethod.POST.toString()),
                                new AntPathRequestMatcher(adminServer.path("/instances/*"), HttpMethod.DELETE.toString()),
                                new AntPathRequestMatcher(adminServer.path("/actuator/**"))
                        )
                );
    }
}
