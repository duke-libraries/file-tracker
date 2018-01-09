require 'rails_helper'

RSpec.describe TrackedChange do

  let(:tracked_file) { TrackedFile.create!(path: path, sha1: sha1, size: 410226) }
  let(:path) { File.join(fixture_path, "nypl.jpg") }
  let(:sha1) { "37781031df4573b90ef045889b7da0ab2655bf74" }
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
        it "resets the size of tracked_file to nil" do
          expect { subject.accept! }.to change(tracked_file, :size).from(410226).to(nil)
        end
        it "resets the sha1 of the tracked_file to nil" do
          expect { subject.accept! }.to change(tracked_file, :sha1).from(sha1).to(nil)
        end
        it "does not change the fixity check time of the tracked file" do
          expect { subject.accept! }.not_to change(tracked_file, :fixity_checked_at)
        end
        it "changes the status of the tracked file" do
          expect { subject.accept! }.to change(tracked_file, :status).to(FileTracker::Status::OK)
        end
        it "marks the change as accepted" do
          expect { subject.accept! }.to change(subject, :change_status).from(described_class::PENDING).to(described_class::ACCEPTED)
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
        it "resets the size of the tracked file to nil" do
          expect { subject.accept! }.to change(tracked_file, :size).to(nil)
        end
        it "resets the sha1 of the tracked_file to nil" do
          expect { subject.accept! }.to change(tracked_file, :sha1).from(sha1).to(nil)
        end
        it "does not change the fixity check time of the tracked file" do
          expect { subject.accept! }.not_to change(tracked_file, :fixity_checked_at)
        end
        it "changes the status of the tracked file" do
          expect { subject.accept! }.to change(tracked_file, :status).to(FileTracker::Status::OK)
        end
        it "marks the change as accepted" do
          expect { subject.accept! }.to change(subject, :change_status).from(described_class::PENDING).to(described_class::ACCEPTED)
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
        expect { subject.reject! }.to change(subject, :change_status).from(described_class::PENDING).to(described_class::REJECTED)
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
        expect { subject.reject! }.to change(subject, :change_status).from(described_class::PENDING).to(described_class::REJECTED)
      end
    end
  end

end
