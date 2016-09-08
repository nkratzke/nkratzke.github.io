import jenkins.model.*
import hudson.model.*
import hudson.security.AuthorizationMatrixProperty

List<String> usernames = Arrays.asList(args);
/*
 * Jobs des ersten Benutzers werden als Vorlage genommen.
 * Dessen Jobs werden fuer alle anderen Benutzer kopiert.
 * Hintergrund: Das Kopieren per Groovy Skript ist wesentlich schneller als das Importieren per CLI.
 * Einmalig muss der Job jedoch fuer einen Benutzer per CLI importiert werden.
 */
String templateUsername = usernames.get(0);
List<String> otherUsernames = usernames.subList(1, usernames.size());

Jenkins instance = Jenkins.getInstance();
for(TopLevelItem job: instance.getItems()){
	String jobName = job.getName();
	if(jobName.endsWith(templateUsername)){
		for(String otherUsername: otherUsernames){
			String otherJobName = jobName.replace(templateUsername, otherUsername);
			println "copying job \"$jobName\" with adjusted permissions to \"$otherJobName\""
			try{
				TopLevelItem otherJob = instance.copy(job, otherJobName);
				addJobPermission(otherJob, otherUsername);
			}
			catch(Exception e){
				println e.getMessage()
			}
		}
		addJobPermission(job, templateUsername);
	}
}

// -------------------- helper methods --------------------

void addJobPermission(TopLevelItem job, String username){
	AuthorizationMatrixProperty p = job.getProperty(hudson.security.AuthorizationMatrixProperty);
	p.add("hudson.model.Item.Read:$username");
	p.add("hudson.model.Item.Build:$username");
	job.save();
}