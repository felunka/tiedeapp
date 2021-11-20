module EmailHelper
  def email_image_tag(image, **options)
    attachments[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
    image_tag attachments[image].url, **options
  end

  def generate_qr_code(token)
    target_url = URI.encode(root_url(token: token))
    return "https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=#{target_url}&choe=UTF-8"
  end
end
