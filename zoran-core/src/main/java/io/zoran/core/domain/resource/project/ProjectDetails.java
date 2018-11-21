package io.zoran.core.domain.resource.project;

import io.zoran.domain.manifest.Manifest;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * @author Michal Sadowski (michal.sadowski@roche.com) on 20.11.2018
 */
@Getter
@Document
@RequiredArgsConstructor
class ProjectDetails {
    @Id
    private final String projectDetailsId;
    private final Manifest billOfMaterials; //PATH TO STORE MAYBE? TODO
    private final String projectName;
    private final String name;
    private String projectLanguage;
    private String groupId;
    private String artifactId;
    private String version;
}