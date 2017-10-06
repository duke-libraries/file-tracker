require 'rails_helper'

RSpec.describe TrackedChange do

  let(:tracked_file) { TrackedFile.create!(path: path, sha1: "37781031df4573b90ef045889b7da0ab2655bf74", md5: "57a88467c003f53d316a92e8896833b0", size: 410226) }
  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:discovered) { DateTime.now }

  describe "accept!" do
    describe "modification" do
      before do
        tracked_file.modified!
        tracked_file.save!
      end
      describe "size" do
        subject {
          described_class.create(tracked_file: tracked_file,
                                 size: 410225,
                                 discovered_at: discovered,
                                 change_type: described_class::MODIFICATION)
        }
        it "updates the size tracked file" do
          expect { subject.accept! }.to change(tracked_file, :size).from(410226).to(410225)
        end
        it "resets the sha1 of the tracked_file to nil" do
          expect { subject.accept! }.to change(tracked_file, :sha1).from("37781031df4573b90ef045889b7da0ab2655bf74").to(nil)
        end
        it "resets the md5 of the tracked file to nil" do
          expect { subject.accept! }.to change(tracked_file, :md5).from("57a88467c003f53d316a92e8896833b0").to(nil)
        end
        it "does not change the fixity check time of the tracked file" do
          expect { subject.accept! }.not_to change(tracked_file, :fixity_checked_at)
        end
        it "changes the status of the tracked file" do
          expect { subject.accept! }.to change(tracked_file, :status).to(FileTracker::Status::OK)
        end
        it "marks the change as accepted" do
          expect { subject.accept! }.to change(subject, :change_status).from(nil).to(described_class::ACCEPTED)
        end
      end
      describe "sha1" do
        subject {
          described_class.create(tracked_file: tracked_file,
                                 size: 410226,
                                 sha1: "37781031df4573b90ef045889b7da0ab2655bf73",
                                 discovered_at: discovered,
                                 change_type: described_class::MODIFICATION)
        }
        it "does not change the size tracked file" do
          expect { subject.accept! }.not_to change(tracked_file, :size)
        end
        it "changes the sha1 of the tracked_file" do
          expect { subject.accept! }.to change(tracked_file, :sha1).from("37781031df4573b90ef045889b7da0ab2655bf74").to("37781031df4573b90ef045889b7da0ab2655bf73")
        end
        it "resets the md5 of the tracked file to nil" do
          expect { subject.accept! }.to change(tracked_file, :md5).from("57a88467c003f53d316a92e8896833b0").to(nil)
        end
        it "does not change the fixity check time of the tracked file" do
          expect { subject.accept! }.not_to change(tracked_file, :fixity_checked_at)
        end
        it "changes the status of the tracked file" do
          expect { subject.accept! }.to change(tracked_file, :status).to(FileTracker::Status::OK)
        end
        it "marks the change as accepted" do
          expect { subject.accept! }.to change(subject, :change_status).from(nil).to(described_class::ACCEPTED)
        end
      end
    end
    describe "deletion" do
      subject {
        described_class.create(tracked_file: tracked_file,
                               discovered_at: discovered,
                               change_type: described_class::DELETION)
      }
      it "destroys the tracked file" do
        subject.accept!
        expect(tracked_file).to be_destroyed
      end
      it "destroys tracked changes related to the tracked file" do
        subject.accept!
        expect { subject.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "reject!" do
    describe "modification" do
      subject {
        described_class.create(tracked_file: tracked_file,
                               size: 410225,
                               discovered_at: discovered,
                               change_type: described_class::MODIFICATION)
      }
      it "does not change the tracked file" do
        expect { subject.reject! }.not_to change { tracked_file }
      end
      it "sets the change status to rejected" do
        expect { subject.reject! }.to change(subject, :change_status).from(nil).to(described_class::REJECTED)
      end
    end
    describe "deletion" do
      subject {
        described_class.create(tracked_file: tracked_file,
                               discovered_at: discovered,
                               change_type: described_class::DELETION)
      }
      it "does not change the tracked file" do
        expect { subject.reject! }.not_to change { tracked_file }
      end
      it "sets the change status to rejected" do
        expect { subject.reject! }.to change(subject, :change_status).from(nil).to(described_class::REJECTED)
      end
    end
  end

end
