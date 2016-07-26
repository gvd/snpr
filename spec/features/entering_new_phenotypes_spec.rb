RSpec.feature 'Entering new phenotypes' do
  let!(:user) { create(:user) }
  let!(:other_user) do
    create(:user, name: 'Max Mustermann', message_on_new_phenotype: true)
  end

  before do
    sign_in(user)
  end

  scenario 'the user enters a new phenotype' do
    visit('/phenotypes')
    click_on('Add a new one!')
    fill_in('Characteristic', with: 'Eye count')
    fill_in('Description', with: 'How many eyes do you have?')
    fill_in('Variation', with: 10)
    click_on('Create Phenotype')
    expect(page.current_path).to eq("/users/#{user.id}")
    phenotype = Phenotype.find_by(characteristic: 'Eye count')
    expect(phenotype).to be_present
    expect(phenotype.number_of_users).to eq(1)
    expect(UserPhenotype.find_by(phenotype: phenotype, user: user).variation).to eq('10')
    expect(user.achievements.map(&:award))
      .to match_array(['Created a new phenotype', 'Entered first phenotype'])
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.first.body.parts.first.body.raw_source)
      .to include((<<-TXT).strip_heredoc.gsub(/ +/, ' '))
        Hello Max Mustermann,

        The new phenotype "Eye count" was just entered on openSNP. If you want \
        to enter your variation for this phenotype, you can visit \
        http://opensnp.org/phenotypes/#{phenotype.id}

        Cheers,
        the openSNP team

        --
        You received this email because you enabled the phenotype-notification \
        setting. To change your notification settings, you can visit \
        http://opensnp.org/users/#{other_user.id}/edit#notifications
      TXT
  end
end
