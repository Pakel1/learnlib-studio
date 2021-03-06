package de.learnlib.studio.experiment.codegen.templates.utils

import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.templates.config.CommandLineOptionsTemplate

class EvaluationWriterTemplate extends AbstractSourceTemplate {
    
    new(GeneratorContext context) {
        super(context, "util", "EvaluationWriter")
    }
    
    override template() '''
         package « package »;
        
        import java.io.IOException;
         import java.nio.file.*;
        
        import « reference(CommandLineOptionsTemplate) »;
        
        
        public class EvaluationWriter {
        
            private EvaluationWriter() {}
        
        
            public static void writeData(Path file, String data) {
                String content = data + "\n";
                try {
                    Files.write(file, content.getBytes(), StandardOpenOption.APPEND);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        
            public static void writeHeader(String counterInformation) {
        
                try {
                   
                    final String fileBaseName = "« context.modelName»_Evaluation";
                    System.out.println("File Base Name: " + fileBaseName);
                    final String experimentStartTime = System.getProperty("EXPERIMENT_START_TIME");
                    String newFileName = fileBaseName + "-" + experimentStartTime + ".csv";
        
                    Path targetFile = Paths.get("result",newFileName);
        
                    if (Files.notExists(targetFile)) {
                        Files.createFile(targetFile);
                    }
                    StringBuffer outputLine = new StringBuffer();
                    outputLine.append("Configuration");
                    outputLine.append("; ");
                    outputLine.append("Algorithm");
                    outputLine.append("; ");
                    outputLine.append("EQ-Oracle");
                    outputLine.append("; ");
                    outputLine.append("SUL");
                    outputLine.append(";");
                    outputLine.append(counterInformation);
                    outputLine.append("; ");
                    outputLine.append("Time (ms)");
        
                    writeData(targetFile, outputLine.toString());
        
                } catch (IOException e) {
                    e.printStackTrace();
                }
                }
        
            public static void writeConfigurationData(String algorithm, String EqOracle, String sul, String counts, long time) {
                try {
                	
                    final String fileBaseName = "« context.modelName»_Evaluation";
                    System.out.println("File Base Name: " + fileBaseName);
                    final String experimentStartTime = System.getProperty("EXPERIMENT_START_TIME");
                    String newFileName = fileBaseName + "-" + experimentStartTime + ".csv";
        
                    Path targetFile = Paths.get("result",newFileName);
        
                    if (Files.notExists(targetFile)) {
                        Files.createFile(targetFile);
                    }
        
                    String currentConfiguration = System.getProperty("« context.modelName ».currentConfiguration");
                    int currentC = 1;
                    if (currentConfiguration != null) {
                        currentC = Integer.parseInt(currentConfiguration);
                    }
        
                    StringBuffer out = new StringBuffer();
                    out.append(currentC);
                    out.append(";");
                    out.append(algorithm);
                    out.append(";");
                    out.append(EqOracle);
                    out.append(";");
                    out.append(sul);
                    out.append(";");
                    out.append(counts);
                    out.append(";");
                    out.append(time);
        
        
        
                    writeData(targetFile, out.toString());
        
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    '''
    
}