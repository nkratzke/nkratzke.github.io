import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.domains.*;

String username = args[0]
String password = args[1]
String id = args[2]

Credentials c = new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, id, null, username, password)
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)