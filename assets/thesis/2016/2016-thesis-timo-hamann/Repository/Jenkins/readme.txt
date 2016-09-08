Zur Verwendung der Skripte muss die Umgebungsvariable "JENKINS_URL" gesetzt sein, zum Beispiel "http://192.168.99.100:8080/".
Die Skripte erwarten folgende Parameter:

0_init_server.sh
	Parameter 1: Benutzername des Administrators
	Parameter 2: Passwort des Administrators
	Parameter 3: E-Mail-Adresse des Administrators
	Parameter 4: SMTP-Host
	Parameter 5: Benutzername zur SMTP Authentifizierung
	Parameter 6: Passwort zur SMTP Authentifizierung
	Parameter 7: Boolean, ob SSL verwendet werden soll
	Parameter 8: SMTP-Port

1_add_tutor.sh
	Parameter 1: E-Mail-Adresse

2_add_credentials.sh
	Parameter 1: Benutzername
	Parameter 2: Passwort
	Parameter 3: Credentials-ID

3_add_musterloesungen_jobs.sh
	Benötigt keine Parameter.
	Verwendet die Werte aus der Datei "musterloesungen_jobs.csv", welche pro Zeile jeweils einen Präfix für den Namen des Jobs sowie den Pfad zur Job-Definition beinhaltet.

4_add_students_with_jobs.sh
	Benötigt keine Parameter.
	Verwendet die Werte aus der Datei "students.txt", welche pro Zeile jeweils eine E-Mail-Adresse eines einzurichtenden Studierenden beinhaltet.
	Verwendet die Werte aus der Datei "student_jobs.csv", welche pro Zeile jeweils einen Präfix für den Namen der Jobs sowie den Pfad zur Job-Definition beinhaltet.

5_set_jobs_enabled.sh
	Parameter 1: Zeichenkette zur Filterung von Jobs. Jobs mit diese Zeichenkette im Titel werden bearbeitet.
	Parameter 2: Boolean, ob die gefilterten Jobs aktiviert (true) oder deaktiviert werden sollen.
	
login.sh
	Parameter 1: Benutzername
	Parameter 2: Passwort

logout.sh
	Benötigt keine Parameter.