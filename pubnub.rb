require 'webrick'
require 'byebug'
require 'json'
require 'securerandom'

# docs: https://www.pubnub.com/docs/sdks/rest-api/subscribe-v-2

server = WEBrick::HTTPServer.new(:Port => ENV["HTTP_PORT"])

server.mount_proc '/v2/subscribe/' do |req, res|
  if JSON.parse(req.query["t"])["t"] == 0
    resp = {
      "t": {
        "t": "#{Time.now.to_f * 1000000}",
        "r": 1
      },
      "m": []
    }
  else
    sleep(50)
    resp = {
      "t": {
        "t": "#{Time.now.to_f * 1000000}",
        "r": 1
      },
      "m":{
        "a": "1", # Shard
        "f": 514, # Flags
        "i": "pn-0ca50551-4bc8-446e-8829-c70b704545fd", #Issuing Client Id
        "s": 1, #Sequence number
        "p": {
          "t": "#{(Time.now-10).to_f * 1000000}",
          "r": 1
        },
      }
    }
  end

  res.body = JSON.dump(resp)
  res.status = 200
end

server.mount_proc '/v2/history' do |req, res|
  res.body = JSON.dump([[], 0,0 ])
  res.status = 200
end

server.mount_proc '/v3/pam/demo/grant' do |req, res|
  res.body = JSON.dump({
    "service": "Access Manager", "status": 200,
    "data": {"token": SecureRandom.hex}
  })
  res.status = 200
end

server.mount_proc '/publish' do |req, res|
  _, action, pub_key, sub_key, _, channel, _, message = req.path.split("/")

  res.body = JSON.dump([1, "Sent", "#{Time.now.to_f * 1000000}"])
  res.status = 200
end

trap 'INT' do server.shutdown end

server.start
