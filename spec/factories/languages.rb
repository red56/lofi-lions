FactoryGirl.define do
  factory :language do
    name { Faker::Lorem.words(4).join(' ') }
    code { Faker::Lorem.words(2).collect{|w| w[0..1]}.join('-') }
    pluralizable_label_other "everything"

    # https://developer.mozilla.org/en/docs/Localization_and_Plurals#List_of_Plural_Rules
    trait :type_0_chinese do
      pluralizable_label_other "everything"
      pluralizable_label_zero ''
      pluralizable_label_one ''
      pluralizable_label_two  ''
      pluralizable_label_few ''
      pluralizable_label_many ''
    end
    trait :type_1_english do
      pluralizable_label_one "is 1"
      pluralizable_label_other "everything else"
      pluralizable_label_zero ''
      pluralizable_label_two  ''
      pluralizable_label_few ''
      pluralizable_label_many ''
    end
    trait :type_7_russian do
      # need to check these interpretations of android <-> mozilla
      pluralizable_label_one "ends in 1, excluding 11"
      pluralizable_label_few "ends in 2-4, excluding 12-14"
      pluralizable_label_other "everything else"
      pluralizable_label_zero ''
      pluralizable_label_two  ''
      pluralizable_label_many ''
    end
    trait :type_12_arabic do
      # need to check these interpretations of android <-> mozilla
      pluralizable_label_zero "is 0"
      pluralizable_label_one "is 1"
      pluralizable_label_two "is 2"
      pluralizable_label_few "ends in 03-10"
      pluralizable_label_many "ends in 00-02 (excluding 0-2)"
      pluralizable_label_other "everything else"
    end
  end
end