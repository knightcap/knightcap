FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "factory.use#{n}@test.com.au"}
    password "111111"
    password_confirmation "111111"
    id 1
  end
  
  factory :user2 , :class => User do |u|
    email "factory.user2@test.com.au"
    password "111111"
    password_confirmation "111111"
    id 2
  end
  
  factory :team do
    name 'TEST'
    id 2
  end
  
  factory :teamsuser do
   role 'admin'
   team_id 2
   user_id 1
  end

  factory :usergroup do
   # name "TeamMember"
  end
  
  factory :admin_role, :class => Usergroup do
    name "Admin"
  end
  
  #setting roles
  factory :member_role, :class => Usergroup do 
    name "TeamMember"
  end
  
  factory :service do
    email_content ="emailcontent"
    sequence(:name) { |n| "service#{n}"}
    team
    
    #service with results
    factory :service_with_results do
      after(:create) do |service, evaluator|
        service.surveys << FactoryGirl.create(:dummy_survey)
      end
    end
    
    factory :service_with_dblist do
      after(:create) do |service, evaluator|
        service.dlists << FactoryGirl.create(:dlist)
        service.blists << FactoryGirl.create(:blist)
      end
    end
  end
  
  factory :dummy_survey, :class => Survey do
  end
  
  factory :result do 
    email "test@email.com"
    
    trait :done do
      done true
    end
    
    trait :not_done do
      done false
      score nil
      comments nil
    end
    
    trait :promoter do
      score 10
    end
    
    trait :neutral do
      score 8
    end
    
    trait :detractor do
      score 3
    end
    
    trait :rubbish_words do
      comments "the the the the the the the the the"
    end
    
    trait :non_rubbish_words do
      comments "good good great great great awesome awesome awesome"
    end
    
    trait :one_month_ago do
      after(:create) do |result, evaluator|
        result.updated_at = DateTime.now - 1.months
      end
    end
    
    factory :new_result, traits: [:not_done]
    factory :promoter_one_month_ago, traits: [:promoter, :done, :one_month_ago]
    factory :neutral_one_month_ago, traits: [:neutral, :done, :one_month_ago]
    factory :detractor_one_month_ago, traits: [:detractor, :done, :one_month_ago]
    factory :promoter_now, traits: [:promoter, :done]
    factory :neutral_now, traits: [:neutral, :done]
    factory :detractor_now, traits: [:detractor, :done]
    factory :useful_comments, traits: [:non_rubbish_words, :done]
    factory :useful_one_month_ago, traits: [:non_rubbish_words, :done, :one_month_ago]
    factory :useless_comments, traits: [:rubbish_words, :done]
    factory :complete_promoter, traits: [ :promoter, :done, :non_rubbish_words]
  end

  factory :dlist do
    email "dlist@email.com"
  end
  
  factory :blist do
    email "blist@email.com"
  end

end