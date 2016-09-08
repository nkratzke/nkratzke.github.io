import hudson.tasks.Mailer

System.getProperties().put("mail.smtp.starttls.enable","true")

String adminAddress = args[0]
def mailerDesc = new Mailer.DescriptorImpl()
mailerDesc.setAdminAddress(adminAddress)
mailerDesc.setReplyToAddress(adminAddress)
mailerDesc.setSmtpHost(args[1])
mailerDesc.setSmtpAuth(args[2], args[3])
mailerDesc.setCharset("UTF-8")
mailerDesc.setUseSsl(Boolean.parseBoolean(args[4]))
mailerDesc.setSmtpPort(args[5])
mailerDesc.save()