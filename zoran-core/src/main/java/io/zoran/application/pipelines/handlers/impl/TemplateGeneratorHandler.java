package io.zoran.application.pipelines.handlers.impl;

import io.zoran.application.indexer.TemplateFactory;
import io.zoran.application.pipelines.domain.Artifact;
import io.zoran.application.pipelines.handlers.AbstractPipelineTask;
import io.zoran.application.template.TemplateProcessor;
import io.zoran.application.template.TemplateProcessorFactory;
import io.zoran.application.template.context.TemplateClassContext;
import io.zoran.application.template.context.TemplateContextTuple;
import io.zoran.application.template.resolvers.FileNameResolver;
import io.zoran.application.template.resolvers.OutputPathResolver;
import io.zoran.application.template.resolvers.PackageNameResolver;
import io.zoran.domain.manifest.Manifest;
import io.zoran.domain.manifest.Template;
import io.zoran.infrastructure.exception.ZoranHandlerException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.List;

import static io.zoran.application.pipelines.handlers.impl.HandlerParamConst.LOCAL_OUTPUT_PATH;

/**
 * @author Michal Sadowski (michal.sadowski@roche.com) on 19.02.2019
 */
@Slf4j
@Handler
@RequiredArgsConstructor
public class TemplateGeneratorHandler extends AbstractPipelineTask {
    private final TemplateFactory templateFactory;
    private final TemplateProcessorFactory processorFactory;
    private Artifact artifact;

    @Override
    public void handle() throws ZoranHandlerException {
        this.artifact = Artifact.instance();
        List<String> dependenciesNames = this.resource.getDependencies();

        for (String dependency : dependenciesNames) {
            Manifest manifest = templateFactory.getManifestForTemplateUsed(dependency);

            try {
                processTemplate(Paths.get(manifest.getPath()), resource.getTemplateData());
            } catch (IOException e) {
                throw new ZoranHandlerException(e.getMessage(), e.getCause());
            }
        }
    }

    private void processTemplate(Path rootDirectoryPath, List<Template> templateData) throws IOException {
        Files.walkFileTree(rootDirectoryPath, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                TemplateProcessor processor = processorFactory.getProcessorForPath(file);
                String templateLanguage = FileNameResolver.resolveLanguageFromTemplate(file);
                if(processor != null) {
                    Template singleTemplateData = templateData.stream()
                                             .filter(x -> x.getName().equals(file.getFileName().toString()))
                                             .findFirst().get();

                    String packageName = PackageNameResolver.resolve(resource, singleTemplateData);
                    String outputFile = OutputPathResolver.resolve(packageName, resource, templateLanguage,
                            singleTemplateData.getPreferredLocation());
                    TemplateClassContext ctx = createCtxForFile(packageName, file, singleTemplateData, outputFile);
                    processor.compile(ctx);
                }

                return FileVisitResult.CONTINUE;
            }
        });
    }

    private TemplateClassContext createCtxForFile(String packageName, Path file, Template template, String outputPath) {
        TemplateContextTuple[] tuples = (TemplateContextTuple[]) template.getContext().stream()
                                                                         .map(x -> TemplateContextTuple.of(x.getName(), x.getValue()))
                                                                         .toArray();

        return TemplateClassContext.builder()
                                   .packageName(packageName)
                                   .templateFile(file)
                                   .additional(tuples)
                                   .outputPath(outputPath)
                                   .projectName(template.getName())
                                   .build();
    }

    @Override
    public Artifact getArtifact() {
        return this.artifact;
    }

    private void registerOutputPathAsArtifact(String outputPath) {
        this.artifact.register(LOCAL_OUTPUT_PATH, outputPath);
    }
}