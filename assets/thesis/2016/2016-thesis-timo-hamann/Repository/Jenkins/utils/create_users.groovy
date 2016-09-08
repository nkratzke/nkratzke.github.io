// https://gist.github.com/hayderimran7/50cb1244cc1e856873a4
// https://gist.github.com/xbeta/e5edcf239fcdbe3f1672

import jenkins.model.*
import hudson.security.*
import hudson.model.*
import hudson.tasks.Mailer
import java.util.Random
import javax.mail.*
import javax.mail.internet.*

boolean isTutor = Boolean.parseBoolean(args[0])
List<String> eMails = Arrays.asList(args).subList(1, args.length);

HudsonPrivateSecurityRealm securityRealm = new HudsonPrivateSecurityRealm(false)
for(String eMail: eMails){
	String username = eMail.substring(0, eMail.indexOf('@'));
	if(User.get(username, false, null) == null){
		println "creating user \"$username\"" 
		String password = generatePassword(10)
		User user = securityRealm.createAccount(username,password)
		user.addProperty(new Mailer.UserProperty(eMail))
		
		if(isTutor){
			addTutorPrivileges(username)
		}
		
		println "sending email with generated password to \"$eMail\""
		String text = "Hallo $username,\ndas Jenkins Passwort lautet $password"
		sendMail(eMail, "Jenkins Zugangsdaten", text)
	}
	else{
		println "user \"$username\" already exists"
	}
}
Jenkins instance = Jenkins.getInstance()
instance.setSecurityRealm(securityRealm)
instance.save()

// -------------------- helper methods --------------------

String generatePassword(int length){
	String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	Random r = new Random()
	StringBuilder password = new StringBuilder()
	for (int i = 0; i < length; i++){
		int index = r.nextInt(chars.length())
		password.append(chars.charAt(index))
	}
	return password.toString()
}

void addTutorPrivileges(String username){
	println "adding tutor privileges to \"$username\"" 
	def strategy = Jenkins.getInstance().getAuthorizationStrategy()
	strategy.add(Hudson.RUN_SCRIPTS, username)
	strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.CREATE, username)
	strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.DELETE, username)
	strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.UPDATE, username)
	strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.VIEW, username)
	strategy.add(Item.BUILD, username)
	strategy.add(Item.CANCEL, username)
	strategy.add(Item.CONFIGURE, username)
	strategy.add(Item.CREATE, username)
	strategy.add(Item.DELETE, username)
	strategy.add(Item.DISCOVER, username)
	strategy.add(Item.READ, username)
	strategy.add(Item.WORKSPACE, username)
}

// https://gist.github.com/quchie/3e02c5d5df8de804e8e0
// http://javadoc.jenkins-ci.org/hudson/tasks/Mailer.DescriptorImpl.html
void sendMail(String to, String subject, String text){
	def mailerDesc = new Mailer.DescriptorImpl()
	String from = mailerDesc.getAdminAddress()
	String username = mailerDesc.getSmtpAuthUserName()
	String password = mailerDesc.getSmtpAuthPassword()
	String host = mailerDesc.getSmtpServer()
	def port = Integer.parseInt(mailerDesc.getSmtpPort())

	def session = Session.getDefaultInstance(System.getProperties())
	def msg = new MimeMessage(session)
	msg.setSubject(subject)
	msg.setText(text)
	msg.setFrom(new InternetAddress(from))
	msg.addRecipient(Message.RecipientType.TO, new InternetAddress(to))

	String protocol = mailerDesc.getUseSsl() ? "smtps" : "smtp"
	Transport transport = session.getTransport(protocol)
	transport.connect(host, port, username, password)
	transport.sendMessage(msg, msg.getAllRecipients())
	transport.close()
}