function save_to_excel(solution, filename)
    % Save solution to Excel file in required format
    
    % Prepare data tables
    uav_data = {};
    deployment_data = {};
    
    % Extract and format solution data
    % (Implementation depends on exact Excel format requirements)
    
    % Write to Excel
    if exist(filename, 'file')
        delete(filename);
    end
    
    % Create tables and write
    writetable(struct2table(uav_data), filename, 'Sheet', 'UAV_Parameters');
    writetable(struct2table(deployment_data), filename, 'Sheet', 'Deployments');
    
    fprintf('Results saved to %s\n', filename);
end