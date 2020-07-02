### AD Domain TRIVADISLAB

To enable a more or less practical connection to the Directory, a simple structure was created for the fictitious company *Trivadis LAB*. The following graphic shows the organization chart including departments and employees for *Trivadis LAB*. All the users listed can be used as test users. The login name corresponds to the last name in lower case. The password for all users is *LAB01schulung*.

!["Trivadis LAB Company"](images/Trivadislabs_Company.png)
*Fig. 3: Organization chart Trivadis LAB Company*

The fictitious company has the following departments:

| ID | Department             | Distinguished Name (DN)                                        | Description          |
|----|------------------------|----------------------------------------------------------------|----------------------|
| 10 | Senior Management      | ``ou=Senior Management,ou=People,dc=trivadislabs,dc=com``      | Senior Management    |
| 20 | Accounting             | ``ou=Accounting,ou=People,dc=trivadislabs,dc=com``             | Accounting           |
| 30 | Research               | ``ou=Research,ou=People,dc=trivadislabs,dc=com``               | Research             |
| 40 | Sales                  | ``ou=Sales,ou=People,dc=trivadislabs,dc=com``                  | Sales + Distribution |
| 50 | Operations             | ``ou=Operations,ou=People,dc=trivadislabs,dc=com``             | Operations           |
| 60 | Information Technology | ``ou=Information Technology,ou=People,dc=trivadislabs,dc=com`` | IT Department        |
| 70 | Human Resources        | ``ou=Human Resources,ou=People,dc=trivadislabs,dc=com``        | Human Resources      |

The following groups were also defined:

| Groups                     | Distinguished Name (DN)                                            | Description                             |
|----------------------------|--------------------------------------------------------------------|-----------------------------------------|
| Trivadis LAB APP Admins    | ``ou=Trivadis LAB APP Admins,ou=Groups,dc=trivadislabs,dc=com``    | Application administrators              |
| Trivadis LAB DB Admins     | ``ou=Trivadis LAB DB Admins,ou=Groups,dc=trivadislabs,dc=com``     | DB Admins from the IT department        |
| Trivadis LAB Developers    | ``ou=Trivadis LAB Developers,ou=Groups,dc=trivadislabs,dc=com``    | Developers from the research department |
| Trivadis LAB Management    | ``ou=Trivadis LAB Management,ou=Groups,dc=trivadislabs,dc=com``    | Management and managers                 |
| Trivadis LAB System Admins | ``ou=Trivadis LAB System Admins,ou=Groups,dc=trivadislabs,dc=com`` | System Admins from the IT department    |
| Trivadis LAB Users         | ``ou=Trivadis LAB Users,ou=Groups,dc=trivadislabs,dc=com``         | All Users                               |