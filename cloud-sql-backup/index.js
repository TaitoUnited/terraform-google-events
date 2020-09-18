const { google } = require("googleapis");
const { auth } = require("google-auth-library");
const sqladmin = google.sqladmin;

exports.main = async (event, context) => {
  const pubsubMessage = JSON.parse(
    Buffer.from(event.data, "base64").toString()
  );
  const authRes = await auth.getApplicationDefault();
  const backupPath = "gs://" + pubsubMessage["backupBucket"] + pubsubMessage["backupPath"];

  const request = {
    auth: authRes.credential,
    project: pubsubMessage["project"],
    instance: pubsubMessage["instance"],
    resource: {
      exportContext: {
        kind: "sql#exportContext",
        fileType: "SQL",
        uri: backupPath + "/backup-" + Date.now() + ".gz",
      },
    },
  };

  sqladmin.instances.export(request, (err, res) => {
    if (err) console.error(err);
    if (res) console.info(res);
  });
};
