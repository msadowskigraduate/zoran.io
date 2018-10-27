package io.zoran.infrastructure.configuration.domain;

import lombok.Data;
import lombok.NonNull;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

/**
 * @author Michal Sadowski (sadochasee@gmail.com) on 29/07/2018.
 */
@Data
@Validated
@ConfigurationProperties
@Component
public class Zoran {
    @NonNull
    private final String git_repository;
    @NonNull
    private final String zoran_directory;
}
