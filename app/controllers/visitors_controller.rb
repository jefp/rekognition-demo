class VisitorsController < ApplicationController

 def add
   #Test if collection exists
   client = Aws::Rekognition::Client.new()
   collections = client.list_collections({}).collection_ids
   client.create_collection({ collection_id: "faceapp_test" }) if !(collections.include? "faceapp_test")
   image=params[:img]
   image=image.gsub("data:image/jpeg;base64,", "")
   name = params[:name]
   name = name.gsub(" ","_")
   @response = client.index_faces({
       collection_id: "faceapp_test",
       external_image_id: name,
       image: {
         bytes: Base64.decode64(image)
       }
     })
     
     render :json => @response.face_records.to_json

  end

 def find
   client = Aws::Rekognition::Client.new()
   image=params[:img]
   image=image.gsub("data:image/jpeg;base64,", "")
   response = client.search_faces_by_image({
     collection_id: "faceapp_test",
     max_faces: 1,
     face_match_threshold: 95,
     image: {
       bytes: Base64.decode64(image)
     }
   })
   if response.face_matches.count > 1
    render json: {:message => "Too many faces found"}.to_json
   elsif response.face_matches.count == 0
   render json: {:message => "No face detected!"}.to_json
   else
     # "Comparison finished - detected #{ response.face_matches[0].face.external_image_id } with #{ response.face_matches[0].face.confidence } accuracy."
   render json:   {:id => response.face_matches[0].face.external_image_id, :confidence => response.face_matches[0].face.confidence, :message => "Face found!"}.to_json
   end
 end

end
