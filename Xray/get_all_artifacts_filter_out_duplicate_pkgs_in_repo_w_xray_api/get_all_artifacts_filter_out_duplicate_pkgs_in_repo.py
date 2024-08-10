# https://stackoverflow.com/questions/78473821/how-to-generate-xray-vulnerabilties-report-using-rest-api-how-to-filter-by-lat
import requests
import os
import json

def get_artifacts(art_url, access_token, repository_name):
    headers = {"Authorization": "Bearer" + " " + access_token}
    offset = 0
    list_of_packages = []
    list_of_data = []

    while True:
        offset_string = "/xray/api/v1/artifacts?num_of_rows=1000&repo=%s&order_by=created&direction=desc&offset=%d" % (repository_name, offset)
        get_artifacts_api = art_url + offset_string
        response = requests.get(get_artifacts_api, headers=headers)
        json_object = response.json()
        list_data = json_object['data']
        for index in range(len(list_data)):
            if list_data[index]['package_id'] not in list_of_packages:
                list_of_packages.append(list_data[index]['package_id'])
                list_of_data.append(list_data[index])
        if json_object['offset'] == -1:
            break
        offset = json_object['offset']

    return list_of_data


if __name__ == "__main__":

    art_url = os.getenv("ART_URL")
    access_token = os.getenv("ACCESS_TOKEN")
    repository_name = os.getenv("REPOSITORY_NAME")

    if art_url is None or access_token is None or repository_name is None:
        print("Require ART_URL and ACCESS_TOKEN and REPOSITORY_NAME env")
        exit()

    list_of_data = get_artifacts(art_url, access_token,repository_name)
    file_path = "output.json"
    with open(file_path, "w") as json_file:
        json.dump(list_of_data, json_file, indent=4)