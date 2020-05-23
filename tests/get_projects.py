from gns3fy import Gns3Connector, Project
from tabulate import tabulate
server = Gns3Connector("http://172.16.253.1:3080")
print(
        tabulate(
            server.projects_summary(is_print=False),
            headers=["Project Name", "Project ID", "Total Nodes", "Status"],
        )
    )
