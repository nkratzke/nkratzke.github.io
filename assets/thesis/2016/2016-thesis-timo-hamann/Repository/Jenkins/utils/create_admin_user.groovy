import jenkins.model.*
import hudson.security.*
import hudson.model.*
import hudson.tasks.Mailer

// Security konfigurieren und admin-Account anlegen
// https://gist.github.com/hayderimran7/50cb1244cc1e856873a4
// https://gist.github.com/xbeta/e5edcf239fcdbe3f1672

String username = args[0]
String password = args[1]
String email = args[2]

Jenkins instance = Jenkins.getInstance()

HudsonPrivateSecurityRealm hudsonRealm = new HudsonPrivateSecurityRealm(false)
User user = hudsonRealm.createAccount(username,password)
user.addProperty(new Mailer.UserProperty(email))
instance.setSecurityRealm(hudsonRealm)

def strategy = new ProjectMatrixAuthorizationStrategy()
strategy.add(Hudson.READ, "authenticated")
for (Permission p : Permission.ALL) {
	strategy.add(p, username)
}

instance.setAuthorizationStrategy(strategy)
instance.save()