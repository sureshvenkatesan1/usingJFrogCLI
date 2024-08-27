# Got it from @Angello
import json

SYSTEM_REPOS = ["TOTAL", "repo"]
# python -m pip install -U prettytable
from prettytable import PrettyTable



# This class defines an Artifactory object that carries its own information
# This helps with readability, re-usability, and to reduce the need to hard code information
class Artifactory:
    def __init__(self, filename, name):
        self.name = name
        self.filename = filename
        self.storage = self.storage()
        self.repos = self.get_repo_list()
        self.repo_details = self.storage["repositoriesSummaryList"]
        self.local, self.remote, self.virtual, self.na = self.get_filtered_repos()


    def storage(self):
        f = open(self.filename)
        storage = json.load(f)
        return storage

    def get_repo_list(self):
        return [summary["repoKey"] for summary in self.storage["repositoriesSummaryList"]]

    def get_filtered_repos(self):
        l, r, v, na = {}, {}, {}, {}
        for summary in self.storage["repositoriesSummaryList"]:
            if summary["repoType"] == "LOCAL":
                l[summary["repoKey"]] = summary
            elif summary["repoType"] == "CACHE":
                r[summary["repoKey"]] = summary
            elif summary["repoType"] == "VIRTUAL":
                v[summary["repoKey"]] = summary
            elif summary["repoType"] == "NA":
                na[summary["repoKey"]] = summary

        return l, r, v, na

    def total_count_vs_sum(self):
        total_files = 0
        total_files_sum = 0

        for summary in self.storage["repositoriesSummaryList"]:
            if summary['repoKey'] == "TOTAL":
                total_files = summary['filesCount']
            else:
                total_files_sum += summary['filesCount']
        print(total_files)
        print(total_files_sum)


class DiffChecker:
    def __init__(self, rt1, rt2):
        self.rt1 = rt1
        self.rt2 = rt2
        self.missing_r1, self.missing_r2 = self.missing_repos()
        self.table = PrettyTable()
        self.table.field_names = ["Repo Name", "Difference", "Repo Type"]

    def missing_repos(self):
        missing_r1 = [str(repo) for repo in self.rt2.repos if repo not in self.rt1.repos]
        missing_r2 = [str(repo) for repo in self.rt1.repos if repo not in self.rt2.repos]
        return missing_r1, missing_r2

    def missing_locals(self):
        missing_r1 = [str(repo) for repo in self.rt2.local if repo in self.missing_r1]
        missing_r2 = [str(repo) for repo in self.rt1.local if repo in self.missing_r2]
        return missing_r1, missing_r2

    def missing_remote(self):
        missing_r1 = [str(repo) for repo in self.rt2.remote if repo in self.missing_r1]
        missing_r2 = [str(repo) for repo in self.rt1.remote if repo in self.missing_r2]
        return  missing_r1, missing_r2

    def missing_virtual(self):
        missing_r1 = [str(repo) for repo in self.rt2.virtual if repo in self.missing_r1]
        missing_r2 = [str(repo) for repo in self.rt1.virtual if repo in self.missing_r2]
        return missing_r1, missing_r2

    def common_repos(self):
        return [str(repo) for repo in self.rt2.repos if repo in self.rt1.repos and repo not in SYSTEM_REPOS]

    def repo_report(self):

        mlr1, mlr2 = self.missing_locals()
        mrr1, mrr2 = self.missing_remote()
        mvr1, mvr2 = self.missing_virtual()

        print("************")
        print("Repositories missing for {}".format(self.rt1.name))
        print("Local: {}".format(mlr1))
        print("Remote: {}".format(mrr1))
        print("Virtual: {}".format(mvr1))
        print("************")
        print("Repositories missing for {}".format(self.rt2.name))
        print("Local: {}".format(mlr2))
        print("Remote: {}".format(mrr2))
        print("Virtual: {}".format(mvr2))
        print("************")
        print("Repositories in Common:")
        print(self.common_repos())
        print("************")

    def local_repos_diff(self):
        print("************")
        print("Checking local repositories in common")
        for repo_name in self.common_repos():
            if repo_name in self.rt1.local.keys() and (self.rt1.local[repo_name]["filesCount"] != self.rt2.local[repo_name]["filesCount"]):
                print("************")
                print("Repository Name: {}".format(repo_name))
                print("Instance {}: {} files, {} used".format(self.rt1.name, self.rt1.local[repo_name]["filesCount"], self.rt1.local[repo_name]["usedSpace"]))
                print("Instance {}: {} files, {} used".format(self.rt2.name, self.rt2.local[repo_name]["filesCount"], self.rt2.local[repo_name]["usedSpace"]))

                diff = self.rt1.local[repo_name]["filesCount"] - self.rt2.local[repo_name]["filesCount"]
                self.table.add_row([repo_name, diff, "LOCAL"])

    def cache_repos_diff(self):
        print("************")
        print("Checking cache repositories in common")
        for repo_name in self.common_repos():
            if repo_name in self.rt1.remote.keys() and (self.rt1.remote[repo_name]["filesCount"] != self.rt2.remote[repo_name]["filesCount"]):
                print("************")
                print("Repository Name: {}".format(repo_name))
                print("Instance {}: {} files, {} used".format(self.rt1.name, self.rt1.remote[repo_name]["filesCount"], self.rt1.remote[repo_name]["usedSpace"]))
                print("Instance {}: {} files, {} used".format(self.rt2.name, self.rt2.remote[repo_name]["filesCount"], self.rt2.remote[repo_name]["usedSpace"]))

                diff = self.rt1.remote[repo_name]["filesCount"] - self.rt2.remote[repo_name]["filesCount"]
                self.table.add_row([repo_name, diff, "CACHE"])

    def virtual_repos_diff(self):
        print("************")
        print("Checking virtual repositories in common")
        for repo_name in self.common_repos():
            if repo_name in self.rt1.virtual.keys() and (self.rt1.virtual[repo_name]["filesCount"] != self.rt2.virtual[repo_name]["filesCount"]):
                print("************")
                print("Repository Name: {}".format(repo_name))
                print("Instance {}: {} files, {} used".format(self.rt1.name, self.rt1.virtual[repo_name]["filesCount"], self.rt1.virtual[repo_name]["usedSpace"]))
                print("Instance {}: {} files, {} used".format(self.rt2.name, self.rt2.virtual[repo_name]["filesCount"], self.rt2.virtual[repo_name]["usedSpace"]))
                diff = self.rt1.virtual[repo_name]["filesCount"] - self.rt2.virtual[repo_name]["filesCount"]
                self.table.add_row([repo_name, diff, "VIRTUAL"])

    def na_repos_diff(self):
        print("************")
        print("Checking NA repositories in common")
        for repo_name in self.rt1.na.keys():
            if repo_name in self.common_repos():
                if self.rt1.na[repo_name]["filesCount"] != self.rt2.na[repo_name]["filesCount"]:
                    print("************")
                    print("Repository Name: {}".format(repo_name))
                    print("Instance {}: {} files, {} used".format(self.rt1.name, self.rt1.na[repo_name]["filesCount"], self.rt1.na[repo_name]["usedSpace"]))
                    print("Instance {}: {} files, {} used".format(self.rt2.name, self.rt2.na[repo_name]["filesCount"], self.rt2.na[repo_name]["usedSpace"]))
                    diff = self.rt1.na[repo_name]["filesCount"] - self.rt2.na[repo_name]["filesCount"]
                    self.table.add_row([repo_name, diff, "NA"])
            elif repo_name not in SYSTEM_REPOS:
                self.table.add_row([repo_name, self.rt1.na[repo_name]["filesCount"], "NA"])


    def repo_content_diff(self, repo_name):
        r1_content = self.rt1.get_repo_content(repo_name)
        r2_content = self.rt2.get_repo_content(repo_name)
        paths_one = []
        paths_two = []

        for result in r1_content:
            path = result['path'] + "/" + result['name']  # put the repo and path of each image in a tuple
            paths_one.append(path)  # put them all on a list

        for result in r2_content:
            path = result['path'] + "/" + result['name']  # put the repo and path of each image in a tuple
            paths_two.append(path)  # put them all on a list

        one_missing = list(set(paths_one) - set(paths_two))
        two_missing = list(set(paths_two) - set(paths_one))

        return one_missing, two_missing




def main():

    file_one = "/Users/sureshv/IdeaProjects/usingJFrogCLI/artifactory/storage/storage-summary.json"
    file_two = "/Users/sureshv/IdeaProjects/usingJFrogCLI/artifactory/storage/storage-summary-161.json"
    art1 = Artifactory(file_one, "Artifactory One")
    art2 = Artifactory(file_two, "Artifactory Two")

    check = DiffChecker(art1, art2)
    check.repo_report()
    check.local_repos_diff()
    check.cache_repos_diff()
    check.virtual_repos_diff()
    check.na_repos_diff()

    print(check.table)

if __name__ == '__main__':
    main()