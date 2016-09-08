import hudson.tasks.Ant
import hudson.tools.InstallSourceProperty
import jenkins.model.*
import hudson.model.*

// Ant installieren
// https://groups.google.com/forum/#!topic/jenkinsci-users/KE7dt0JKHvk

def ant = new Ant.AntInstallation('ant_1.9.7', '/var/jenkins_home/tools/hudson.tasks.Ant_AntInstallation/ant_1_9_7', [new InstallSourceProperty([new Ant.AntInstaller('1.9.7')])])

antDescriptor = Jenkins.instance.getExtensionList(hudson.tasks.Ant.DescriptorImpl.class)[0];
antDescriptor.setInstallations(ant)
antDescriptor.save()