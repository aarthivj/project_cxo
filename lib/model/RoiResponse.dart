class RoiResponse {
    RoiResponse({
        required this.data,
        required this.status,
        required this.datelist,
        required this.queuenames,
        required this.cumulativecost,
        required this.cumulativesaving,
        required this.humanCost,
        required this.allRoIdata,
        required this.allQueueName,
        required this.results,
    });

    final List<Datum> data;
    final String? status;
    final List<DateTime> datelist;
    final List<Queuename> queuenames;
    final List<int> cumulativecost;
    final List<int> cumulativesaving;
    final List<int> humanCost;
    final List<AllRoIdatum> allRoIdata;
    final List<String> allQueueName;
    final List<Datum> results;

    factory RoiResponse.fromJson(Map<String, dynamic> json){ 
        return RoiResponse(
            data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
            status: json["status"],
            datelist: json["datelist"] == null ? [] : List<DateTime>.from(json["datelist"]!.map((x) => DateTime.tryParse(x ?? ""))),
            queuenames: json["queuenames"] == null ? [] : List<Queuename>.from(json["queuenames"]!.map((x) => Queuename.fromJson(x))),
            cumulativecost: json["cumulativecost"] == null ? [] : List<int>.from(json["cumulativecost"]!.map((x) => x)),
            cumulativesaving: json["cumulativesaving"] == null ? [] : List<int>.from(json["cumulativesaving"]!.map((x) => x)),
            humanCost: json["human_cost"] == null ? [] : List<int>.from(json["human_cost"]!.map((x) => x)),
            allRoIdata: json["allROIdata"] == null ? [] : List<AllRoIdatum>.from(json["allROIdata"]!.map((x) => AllRoIdatum.fromJson(x))),
            allQueueName: json["allQueueName"] == null ? [] : List<String>.from(json["allQueueName"]!.map((x) => x)),
            results: json["results"] == null ? [] : List<Datum>.from(json["results"]!.map((x) => Datum.fromJson(x))),
        );
    }

}

class AllRoIdatum {
    AllRoIdatum({
        required this.roiId,
        required this.processForAutomation,
        required this.headCount,
        required this.hoursSpent,
        required this.hourlyRate,
        required this.avgTimeManualEffort,
        required this.monthlyInvoiceBot,
        required this.userEmail,
        required this.clientName,
        required this.operationalModel,
        required this.additionalLoadCost,
        required this.onsiteHeadCount,
        required this.onsiteHoursSpent,
        required this.onsiteHourlyRate,
        required this.onsiteAdditionalLoadCost,
        required this.offshoreHeadCount,
        required this.offshoreHoursSpent,
        required this.offshoreHourlyRate,
        required this.offshoreAdditionalLoadCost,
    });

    final int? roiId;
    final String? processForAutomation;
    final int? headCount;
    final int? hoursSpent;
    final double? hourlyRate;
    final int? avgTimeManualEffort;
    final int? monthlyInvoiceBot;
    final dynamic userEmail;
    final String? clientName;
    final String? operationalModel;
    final int? additionalLoadCost;
    final int? onsiteHeadCount;
    final double? onsiteHoursSpent;
    final double? onsiteHourlyRate;
    final int? onsiteAdditionalLoadCost;
    final int? offshoreHeadCount;
    final int? offshoreHoursSpent;
    final double? offshoreHourlyRate;
    final int? offshoreAdditionalLoadCost;

    factory AllRoIdatum.fromJson(Map<String, dynamic> json){ 
        return AllRoIdatum(
            roiId: json["roi_id"],
            processForAutomation: json["process_for_automation"],
            headCount: json["head_count"],
            hoursSpent: json["hours_spent"],
            hourlyRate: json["hourly_rate"],
            avgTimeManualEffort: json["avg_time_manual_effort"],
            monthlyInvoiceBot: json["monthly_invoice_bot"],
            userEmail: json["user_email"],
            clientName: json["client_name"],
            operationalModel: json["operational_model"],
            additionalLoadCost: json["additional_load_cost"],
            onsiteHeadCount: json["onsite_head_count"],
            onsiteHoursSpent: json["onsite_hours_spent"],
            onsiteHourlyRate: json["onsite_hourly_rate"],
            onsiteAdditionalLoadCost: json["onsite_additional_load_cost"],
            offshoreHeadCount: json["offshore_head_count"],
            offshoreHoursSpent: json["offshore_hours_spent"],
            offshoreHourlyRate: json["offshore_hourly_rate"],
            offshoreAdditionalLoadCost: json["offshore_additional_load_cost"],
        );
    }

}

class Datum {
    Datum({
        required this.status,
        required this.agentName,
        required this.subscribtionData,
        required this.cumulativecost,
        required this.datelist,
        required this.cumulativesaving,
        required this.humanCost,
        required this.prevCumulativeSavings,
        required this.humanCostPerDay,
        required this.botCostPerDay,
        required this.humanTransPerDay,
        required this.roidata,
    });

    final String? status;
    final String? agentName;
    final List<SubscribtionDatum> subscribtionData;
    final List<int> cumulativecost;
    final List<DateTime> datelist;
    final List<int> cumulativesaving;
    final List<int> humanCost;
    final double? prevCumulativeSavings;
    final double? humanCostPerDay;
    final double? botCostPerDay;
    final int? humanTransPerDay;
    final AllRoIdatum? roidata;

    factory Datum.fromJson(Map<String, dynamic> json){ 
        return Datum(
            status: json["status"],
            agentName: json["agent_name"],
            subscribtionData: json["subscribtion_data"] == null ? [] : List<SubscribtionDatum>.from(json["subscribtion_data"]!.map((x) => SubscribtionDatum.fromJson(x))),
            cumulativecost: json["cumulativecost"] == null ? [] : List<int>.from(json["cumulativecost"]!.map((x) => x)),
            datelist: json["datelist"] == null ? [] : List<DateTime>.from(json["datelist"]!.map((x) => DateTime.tryParse(x ?? ""))),
            cumulativesaving: json["cumulativesaving"] == null ? [] : List<int>.from(json["cumulativesaving"]!.map((x) => x)),
            humanCost: json["human_cost"] == null ? [] : List<int>.from(json["human_cost"]!.map((x) => x)),
            prevCumulativeSavings: json["prev_cumulative_savings"],
            humanCostPerDay: json["human_cost_per_day"],
            botCostPerDay: json["bot_cost_per_day"],
            humanTransPerDay: json["human_trans_per_day"],
            roidata: json["roidata"] == null ? null : AllRoIdatum.fromJson(json["roidata"]),
        );
    }

}

class SubscribtionDatum {
    SubscribtionDatum({
        required this.area,
        required this.agentName,
        required this.queueName,
        required this.goLiveDate,
        required this.cost,
        required this.currentBot,
    });

    final String? area;
    final String? agentName;
    final String? queueName;
    final DateTime? goLiveDate;
    final int? cost;
    final int? currentBot;

    factory SubscribtionDatum.fromJson(Map<String, dynamic> json){ 
        return SubscribtionDatum(
            area: json["area"],
            agentName: json["agent_name"],
            queueName: json["queue_name"],
            goLiveDate: DateTime.tryParse(json["go_live_date"] ?? ""),
            cost: json["cost"],
            currentBot: json["current_bot"],
        );
    }

}

class Queuename {
    Queuename({
        required this.queueName,
        required this.departmentId,
        required this.labelName,
    });

    final String? queueName;
    final int? departmentId;
    final String? labelName;

    factory Queuename.fromJson(Map<String, dynamic> json){ 
        return Queuename(
            queueName: json["queue_name"],
            departmentId: json["departmentId"],
            labelName: json["label_name"],
        );
    }

}
