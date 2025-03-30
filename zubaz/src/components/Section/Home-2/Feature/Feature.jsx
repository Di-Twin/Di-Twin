import FeatureCardTwo from "~/components/Ui/Cards/FeatureTwo";

const FeatureSection = () => {
  return (
    <div className="section zubuz-section-padding1">
      <div className="container">
        <div className="zubuz-section-title center">
          <h2 className="wider-heading">
            From Patterns to Progress Own Your Health.
          </h2> 
        </div>
        <div className="row">
          <div className="col-lg-6">
            <FeatureCardTwo
              icon="/images/v2/icon-v2-1.png"
              title="Heart Rate Monitoring"
              description="Track heart rate trends, detect irregularities, and receive real-time health alerts with AI-driven analysis."
              image="/images/v2/card-v2-1.png"
            />
            <FeatureCardTwo
              icon="/images/v2/icon-v2-3.png"
              title="Sleep Optimization"
              description="Get AI-powered sleep insights, detect disruptions, and improve your rest with personalized recommendations."
              image="/images/v2/card-v2-3.png"
            />
          </div>
          <div className="col-lg-6">
            <FeatureCardTwo
              icon="/images/v2/icon-v2-2.png"
              title="Activity Tracking"
              description="Analyze workouts, step count, and calorie burn—sync with wearables for real-time fitness insights."
              image="/images/v2/card-v2-2.png"
            />
            <FeatureCardTwo
              icon="/images/v2/icon-v2-4.png"
              title="Medications & Alerts"
              description="Never miss a dose! Smart reminders and AI-powered tracking ensure medication adherence for better health."
              image="/images/v2/card-v2-4.png"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default FeatureSection;
