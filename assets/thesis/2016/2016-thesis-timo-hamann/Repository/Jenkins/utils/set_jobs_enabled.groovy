import jenkins.model.*
import hudson.model.*

String searchText = args[0]
boolean enable = Boolean.parseBoolean(args[1])

for(Item job: Jenkins.instance.items){
  if(job.name.contains(searchText)){
	if(enable){
		println "enabling job ${job.name}"
		job.enable()
	}
	else{
		println "disabling job ${job.name}"
		job.disable()
	}
  }
}